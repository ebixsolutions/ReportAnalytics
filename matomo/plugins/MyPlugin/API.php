<?php
/**
 * Matomo - free/libre analytics platform
 *
 * @link https://matomo.org
 * @license http://www.gnu.org/licenses/gpl-3.0.html GPL v3 or later
 *
 */
namespace Piwik\Plugins\MyPlugin;

use Piwik\DataTable\Row;
use Piwik\DataTable;
use Piwik\Piwik;
use Piwik\Version;
use Piwik\Common;

use Piwik\API\Request;
use Piwik\Config;
use Piwik\Plugins\Goals\API as APIGoals;
use Piwik\Plugins\Live\Visualizations\VisitorLog;
use Piwik\Url;
use Piwik\View;
use Piwik\Plugins\Live;
use Piwik\ArchiveProcessor;
use Piwik\Site;

use Piwik\Date;
use Piwik\Plugins\SitesManager\API as APISitesManager;
use Psr\Log\LoggerInterface;
use Piwik\Db;

use Piwik\Plugins\Live\VisitorFactory;
use Piwik\Plugins\Live\Visitor;


/**
 * The ExampleAPI is useful to developers building a custom Matomo plugin.
 *
 * Please see the <a href='https://github.com/piwik/piwik/blob/master/plugins/ExampleAPI/API.php' rel='noreferrer' target='_blank'>source code in in the file plugins/ExampleAPI/API.php</a> for more documentation.
 * @method static \Piwik\Plugins\ExampleAPI\API getInstance()
 */
class API extends \Piwik\Plugin\API
{
    // Get Last Visit Details
    public function getLastVisitsDetails($idSite, $period = false, $date = false, $segment = false, $countVisitorsToFetch = false, $minTimestamp = false, $flat = false, $doNotFetchActions = false, $enhanced = false, $is_group = false){

        Piwik::checkUserHasViewAccess($idSite);

        $default_from = date('Y-m-d', strtotime('-30 day'));
        $default_to = date('Y-m-d');

        if($date!=''){
            $given_date = explode(',', $date);
            $default_from = $given_date[0];
            $default_to = $given_date[0];
            if(isset($given_date[1])){
                $default_to = $given_date[1];
            }
        }

        $db = Db::get();
        $table = 'matomo_log_visit';
        $dateCondition = '';
        $sql = "select * from %s 
        WHERE matomo_log_visit.idSite=%s AND
        matomo_log_visit. visit_last_action_time >= '%s' 
        AND matomo_log_visit.visit_last_action_time <= '%s'"; 

        if($is_group==true) {
            $sql = "select *, count(user_id) as total_views_by_ip from %s 
            WHERE matomo_log_visit.idSite=%s AND
            matomo_log_visit. visit_last_action_time >= '%s' 
            AND matomo_log_visit.visit_last_action_time <= '%s' GROUP BY user_id,location_ip ORDER BY matomo_log_visit.visit_last_action_time DESC"; 
        }


        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $default_from, $default_to);
        
        $dataRows = $db->fetchAll($sql, $bind);

        $dataTable = $this->makeVisitorTableFromArray($dataRows);
        $this->addFilterToCleanVisitors($dataTable, $idSite, false, false);
        return $dataTable;
    }


    private function addFilterToCleanVisitors(DataTable $dataTable, $idSite, $flat = false, $doNotFetchActions = false, $filterNow = false)
    {
        $filter = 'queueFilter';
        if ($filterNow) {
            $filter = 'filter';
        }

        $dataTable->$filter(function ($table) use ($idSite, $flat, $doNotFetchActions) {

            /** @var DataTable $table */
            $visitorFactory = new VisitorFactory();

            // live api is not summable, prevents errors like "Unexpected ECommerce status value"
            $table->deleteRow(DataTable::ID_SUMMARY_ROW);

            $actionsByVisitId = array();

            if (!$doNotFetchActions) {
                $visitIds = $table->getColumn('idvisit');
                $visitorDetailsManipulators = Visitor::getAllVisitorDetailsInstances();
                foreach ($visitorDetailsManipulators as $instance) {
                    $instance->provideActionsForVisitIds($actionsByVisitId, $visitIds);
                }
            }
            foreach ($table->getRows() as $visitorDetailRow) {

                $visitorDetailsArray = Visitor::cleanVisitorDetails($visitorDetailRow->getColumns());
                $visitor = $visitorFactory->create($visitorDetailsArray);
                $visitorDetailsArray = $visitor->getAllVisitorDetails();
                $visitorDetailsArray['actionDetails'] = array();
                if (!$doNotFetchActions) {
                    $bulkFetchedActions  = isset($actionsByVisitId[$visitorDetailsArray['idVisit']]) ? $actionsByVisitId[$visitorDetailsArray['idVisit']] : array();
                    $visitorDetailsArray = Visitor::enrichVisitorArrayWithActions($visitorDetailsArray, $bulkFetchedActions);
                }

                if ($flat) {
                    $visitorDetailsArray = Visitor::flattenVisitorDetailsArray($visitorDetailsArray);
                }

                $visitorDetailsArray['total_views_by_ip'] = 0;

                if(isset($visitorDetailRow['total_views_by_ip'])){

                    $visitorDetailsArray['total_views_by_ip'] = $visitorDetailRow['total_views_by_ip'];
                }
                $visitorDetailRow->setColumns($visitorDetailsArray);
            }
        });
    }


    /**
     * @param $data
     * @param $hasMoreVisits
     * @return DataTable
     * @throws Exception
     */
    private function makeVisitorTableFromArray($data, $hasMoreVisits=null)
    {
        $dataTable = new DataTable();

        $dataTable->addRowsFromSimpleArray($data);

        if (!empty($data[0])) {
            $columnsToNotAggregate = array_map(function () {
                return 'skip';
            }, $data[0]);

            $dataTable->setMetadata(DataTable::COLUMN_AGGREGATION_OPS_METADATA_NAME, $columnsToNotAggregate);
        }

        if (null !== $hasMoreVisits) {
            $dataTable->setMetadata('hasMoreVisits', $hasMoreVisits);
        }

        return $dataTable;
    }
}