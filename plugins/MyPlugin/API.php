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

use Piwik\CacheId;

use Matomo\Cache\Lazy;
use Piwik\Cache as PiwikCache;

use Piwik\DataTable\Renderer\Json;

/**
 * The ExampleAPI is useful to developers building a custom Matomo plugin.
 *
 * Please see the <a href='https://github.com/piwik/piwik/blob/master/plugins/ExampleAPI/API.php' rel='noreferrer' target='_blank'>source code in in the file plugins/ExampleAPI/API.php</a> for more documentation.
 * @method static \Piwik\Plugins\ExampleAPI\API getInstance()
 */
class API extends \Piwik\Plugin\API
{
	
    public function __construct(Lazy $cache)
    {
        $this->cache = $cache;
    }

    
    // Get Region List 
    public function getRegionList($q=''){

        if($q==''){
            return [];
        }
        
        $filename = getcwd().'/plugins/MyPlugin/region_data.json';
        $data = file_get_contents($filename);

        $data = json_decode($data, true);
        $q='%'.$q.'%';
        foreach ($data as $key => $country) {

            $is_matched = false;
            foreach ($country['regions'] as $key1 => $country_region) {

                if($this->like_match($q, $country_region['name'])==true){

                    $final_array[$key+$key1]['country_name']=$country['countryName'];

                    $final_array[$key+$key1]['country_code']=$country['countryShortCode'];

                    $final_array[$key+$key1]['region_name']=$country_region['name'];

                    $final_array[$key+$key1]['region_code']=$country_region['shortCode'];
                }
            }
        }

        //print_r($final_array);

        return $final_array;

        return json_decode($final_array, true);
    }

    function like_match($pattern, $subject)
    {
        $pattern = str_replace('%', '.*', preg_quote($pattern, '/'));
        return (bool) preg_match("/^{$pattern}$/i", $subject);
    }


    // Add to Cart Not Checkout Count
    public function getCheckoutCount($idSite, $type='last_one_year', $date=false){


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

        if($type=='last_one_year'){
            $default_from = date('Y-m-d', strtotime('-1 years'));
            $default_to = date('Y-m-d');
        }

        if($type=='last_six_month'){
            $default_from = date('Y-m-d', strtotime('-6 months'));
            $default_to = date('Y-m-d');
        }

        if($type=='last_three_month'){
            $default_from = date('Y-m-d', strtotime('-3 months'));
            $default_to = date('Y-m-d');
        }

        $db = Db::get();
        $table = 'matomo_log_visit';
        $dateCondition = '';
        $sql = "select count(*) as total_count from %s 
        WHERE matomo_log_visit.idSite=%s AND
        matomo_log_visit.visit_last_action_time >= '%s' 
        AND matomo_log_visit.visit_last_action_time <= '%s'
        AND (custom_var_k1='is_added_to_cart' AND custom_var_v1='true') AND  
        (custom_var_k2='is_checkout' OR custom_var_k2 IS NULL) AND 
        (custom_var_v2='false' OR custom_var_v2 IS NULL);";

        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59");
        $dataRows = $db->fetchAll($sql, $bind);
        return $dataRows[0]['total_count'];
    }
    public function label_Update($unique_action_id,$labels){
        $db = Db::get();
        $sql = "UPDATE `matomo_log_link_visit_action` SET `custom_dimension_6` = '".$labels."' WHERE `custom_dimension_14` =".$unique_action_id.";";
        $db->query($sql);

        return $sql;
        // where custom_dimension_14 = unique_action_id
        // update custom_dimension_6 = ['label1',label2]
    }

    // Get matomo action details 
    public function getMatomoCampaignActionDetails($user_id, $user_name='', $idSite, $startDate, $endDate, $flat=false){

        Piwik::checkUserHasViewAccess($idSite);

        $default_from = date('Y-m-d');
        $default_to = date('Y-m-d');

        if($startDate!=''){
            $default_from = date('Y-m-d', strtotime($startDate));
        }

        if($endDate!=''){
            $default_to = date('Y-m-d', strtotime($endDate));
        }

        $user_query = '';
        if($user_id!='' && $user_name!=''){
            $user_query = 'AND ( matomo_log_visit.user_id='.$user_id. ' OR matomo_log_visit.user_id='.$user_name.')';
        }
        else if($user_id!=''){
            $user_query = 'AND matomo_log_visit.user_id='.$user_id;
        }
        else{
            $user_query = 'AND matomo_log_visit.user_id='.$user_name;
        }

        if($user_query==''){
            return [];
        }

        $db1 = Db::get();
        $db1->exec("SET SESSION group_concat_max_len = 1000000;");

        $db = Db::get();
        $table = 'matomo_log_link_visit_action';
        $dateCondition = '';
        $sql = "select group_concat(DISTINCT matomo_log_link_visit_action.custom_dimension_3) as campaign_id from %s JOIN matomo_log_visit ON matomo_log_visit.idvisit=matomo_log_link_visit_action.idvisit
        WHERE matomo_log_link_visit_action.idSite=%s AND
        matomo_log_link_visit_action.custom_dimension_3!='' AND
        matomo_log_link_visit_action.server_time >= '%s' 
        AND matomo_log_link_visit_action.server_time <= '%s'".$user_query;
        $sql = $sql." LIMIT %s,%s";

        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59", 0, 1);
        $dataRows = $db->fetchAll($sql, $bind);

        if(count($dataRows) > 0){
           return  explode(',', $dataRows[0]['campaign_id']);
        }
        return [];
    }

    // Get Current Vistor Details 
    public function getCurrentVistorDetails($user_id, $user_name='', $idSite, $flat = false, $doNotFetchActions = false){
        Piwik::checkUserHasViewAccess($idSite);
        $default_from = date('Y-m-d');
        $default_to = date('Y-m-d');

        $user_query = '';
        if($user_id!='' && $user_name!=''){
            $user_query = 'AND ( matomo_log_visit.user_id='.$user_id. ' OR matomo_log_visit.user_id='.$user_name.')';
        }
        else if($user_id!=''){
            $user_query = 'AND matomo_log_visit.user_id='.$user_id;
        }
        else{
            $user_query = 'AND matomo_log_visit.user_id='.$user_name;
        }

        if($user_query==''){
            return [];
        }

        $db = Db::get();
        $table = 'matomo_log_visit';
        $dateCondition = '';
        $sql = "select * from %s 
        WHERE matomo_log_visit.idSite=%s AND
        matomo_log_visit. visit_last_action_time >= '%s' 
        AND matomo_log_visit.visit_last_action_time <= '%s'".$user_query;
        $sql = $sql." LIMIT %s,%s"; 

        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59", 0, 1);
        $dataRows = $db->fetchAll($sql, $bind);
        return $dataRows;
    }

    // Get Vistor Details 
    public function getVistorDetails($idSite, $idVisit, $flat = false, $doNotFetchActions = false){
        Piwik::checkUserHasViewAccess($idSite);
        $db = Db::get();
        $table = 'matomo_log_visit';
        $dateCondition = '';
        $sql = "select * from %s 
        WHERE matomo_log_visit.idSite=%s AND
        matomo_log_visit.idvisit=%s"; 
        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $idVisit);
        $dataRows = $db->fetchAll($sql, $bind);
        $dataTable = $this->makeVisitorTableFromArray($dataRows);
        $this->addFilterToCleanVisitors($dataTable, $idSite, $flat, $doNotFetchActions);
        return $dataTable;
    }

    // Get Last Visit Details
    public function getLastVisitsDetails($idSite, $period = false, $date = false, $segment = false, $countVisitorsToFetch = false, $minTimestamp = false, $flat = false, $doNotFetchActions = false, $enhanced = false, $is_group = 0, $type='last_one_year', $filter_offset=1, $filter_limit=10,$is_download=false){

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

        if($type=='last_one_year'){
            $default_from = date('Y-m-d', strtotime('-1 years'));
            $default_to = date('Y-m-d');
        }

        if($type=='last_six_month'){
            $default_from = date('Y-m-d', strtotime('-6 months'));
            $default_to = date('Y-m-d');
        }

        if($type=='last_three_month'){
            $default_from = date('Y-m-d', strtotime('-3 months'));
            $default_to = date('Y-m-d');
        }

        if($type=='custom_date_range'){

            $db = Db::get();
            $table = 'matomo_log_visit';
            $dateCondition = '';
            $sql = "select * from %s 
            WHERE matomo_log_visit.idSite=%s AND
            matomo_log_visit. visit_last_action_time >= '%s' 
            AND matomo_log_visit.visit_last_action_time <= '%s'
            ORDER BY matomo_log_visit.visit_last_action_time DESC LIMIT %s,%s";

            $count_sql="select count(*) as total_count from %s 
            WHERE matomo_log_visit.idSite=%s AND
            matomo_log_visit. visit_last_action_time >= '%s' 
            AND matomo_log_visit.visit_last_action_time <= '%s'";

            if($is_group==true) {
                $sql = "select *, count(user_id) as total_views_by_ip from %s 
                WHERE matomo_log_visit.idSite=%s AND
                matomo_log_visit. visit_last_action_time >= '%s' 
                AND matomo_log_visit.visit_last_action_time <= '%s' GROUP BY user_id,location_ip ORDER BY matomo_log_visit.visit_last_action_time DESC LIMIT %s,%s"; 

                $count_sql="select count(*) as total_count from %s 
                WHERE matomo_log_visit.idSite=%s AND
                matomo_log_visit. visit_last_action_time >= '%s' 
                AND matomo_log_visit.visit_last_action_time <= '%s' GROUP BY user_id,location_ip";
            }
            $bind = array();
            $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59", $filter_offset, $filter_limit);
            $dataRows = $db->fetchAll($sql, $bind);

            $count_sql = sprintf($count_sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59");
            $countRows = $db->fetchAll($count_sql, $bind);

            $total_count = $countRows[0]['total_count'];

            $dataTable = $this->makeVisitorTableFromArray($dataRows);
            $this->addFilterToCleanVisitors($dataTable, $idSite, $flat, $doNotFetchActions, false, $total_count, $filter_limit);
            return $dataTable;
        }
        else 
        {
            $cache = $this->cache;
            $cacheKey = 'tracking_list_'.$is_group."_".$type."_".(int) $idSite;
            $visitors = $cache->fetch($cacheKey);
            if (is_array($visitors)) {
                $dataRows  = $visitors;      
            }
            else {
                $db = Db::get();
                $table = 'matomo_log_visit';
                $dateCondition = '';
                $sql = "select * from %s 
                WHERE matomo_log_visit.idSite=%s AND
                matomo_log_visit. visit_last_action_time >= '%s' 
                AND matomo_log_visit.visit_last_action_time <= '%s'
                ORDER BY matomo_log_visit.visit_last_action_time DESC";

                if($is_group==true) {
                    $sql = "select *, count(user_id) as total_views_by_ip from %s 
                    WHERE matomo_log_visit.idSite=%s AND
                    matomo_log_visit. visit_last_action_time >= '%s' 
                    AND matomo_log_visit.visit_last_action_time <= '%s' GROUP BY user_id,location_ip ORDER BY matomo_log_visit.visit_last_action_time DESC"; 
                }
                $bind = array();
                if($is_download==1){
                    $sql = $sql." LIMIT %s,%s";
                    $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59", $filter_offset, $filter_limit);
                }
                else {
                    $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59");
                }
                $dataRows = $db->fetchAll($sql, $bind);
                if($is_download==0 || $is_download==false){
                    $cache->delete($cacheKey);
                    $cache->save($cacheKey, $dataRows, 3600);
                }
            }
            $dataTable = $this->makeVisitorTableFromArray($dataRows);
            $this->addFilterToCleanVisitors($dataTable, $idSite, $flat, $doNotFetchActions, false, count($dataRows), $filter_limit);
            return $dataTable;
        }
    }

    public function refreshCacheResult($idSite, $period = false, $date = false, $segment = false, $countVisitorsToFetch = false, $minTimestamp = false, $flat = false, $doNotFetchActions = false, $enhanced = false, $is_group = 0, $is_download=false){

        Piwik::checkUserHasViewAccess($idSite);

        $default_from = date('Y-m-d', strtotime('-1 years'));
        $default_to = date('Y-m-d');

        $db = Db::get();
        $table = 'matomo_log_visit';
        $dateCondition = '';
        $sql = "select * from %s 
        WHERE matomo_log_visit.idSite=%s AND
        matomo_log_visit. visit_last_action_time >= '%s' 
        AND matomo_log_visit.visit_last_action_time <= '%s'
        ORDER BY matomo_log_visit.visit_last_action_time DESC";

        if($is_group==true) {
            $sql = "select *, count(user_id) as total_views_by_ip from %s 
            WHERE matomo_log_visit.idSite=%s AND
            matomo_log_visit. visit_last_action_time >= '%s' 
            AND matomo_log_visit.visit_last_action_time <= '%s' GROUP BY user_id,location_ip ORDER BY matomo_log_visit.visit_last_action_time DESC"; 
        }
        $bind = array();
        $sql = sprintf($sql, $table, $idSite, $default_from." 00:00:00", $default_to." 23:59:59");
        $dataRows = $db->fetchAll($sql, $bind);

        $expiry_time = 3600;
        $cache = $this->cache;
        $type=['last_three_month', 'last_six_month', 'last_one_year'];
        foreach ($type as $key => $value) {
            $cacheKey = 'tracking_list_'.$is_group."_".$value."_".(int) $idSite;
            if($value=='last_one_year'){

                $cache->delete($cacheKey);
                $cache->save($cacheKey, $dataRows, $expiry_time);
            }
            else if($value=='last_six_month'){

                $last_six_month=[];
                $default_from = date('Y-m-d', strtotime('-6 months'));
                $default_to = date('Y-m-d');
                foreach ($dataRows as $key => $new_value) {
                    if(date('Y-m-d', strtotime($new_value['visit_last_action_time'])) >= $default_from && date('Y-m-d', strtotime($new_value['visit_last_action_time'])) <= $default_to){
                        array_push($last_six_month, $new_value);
                    }
                }

                $cache->delete($cacheKey);
                $cache->save($cacheKey, $last_six_month, $expiry_time);
            }
            else if($value=='last_three_month'){
                $last_three_month=[];
                $default_from = date('Y-m-d', strtotime('-3 months'));
                $default_to = date('Y-m-d');
                foreach ($dataRows as $key => $new_value) {
                    if(date('Y-m-d', strtotime($new_value['visit_last_action_time'])) >= $default_from && date('Y-m-d', strtotime($new_value['visit_last_action_time'])) <= $default_to){
                        array_push($last_three_month, $new_value);
                    }
                }
                $cache->delete($cacheKey);
                $cache->save($cacheKey, $last_three_month, $expiry_time);
            }
        }

        return true;
    }

    private function addFilterToCleanVisitors(DataTable $dataTable, $idSite, $flat = false, $doNotFetchActions = false, $filterNow = false, $total_count=0, $limit=10)
    {
        $filter = 'queueFilter';
        if ($filterNow) {
            $filter = 'filter';
        }

        $dataTable->$filter(function ($table) use ($idSite, $flat, $doNotFetchActions, $total_count, $limit) {

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

                $visitorDetailsArray['total_count'] = $total_count;
                $visitorDetailsArray['limit'] = $limit;

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
	public function createDimension($site_id)
    {

		$db = Db::get();
		$dimension = '[{"dimension":"url","pattern":""}]';			
		$sql="INSERT INTO `matomo_custom_dimensions` (`idcustomdimension`, `idsite`, `name`, `index`, `scope`, `active`, `extractions`, `case_sensitive`) VALUES (1, '$site_id', 'visit_product_id', 1, 'action', 1,'$dimension', 1),(2, '$site_id', 'visit_varient_id', 2, 'action', 1, '$dimension', 1),(3, '$site_id', 'campaign_id', 3, 'action', 1, '$dimension', 1),(4, '$site_id', 'campaign_name', 4, 'action', 1, '$dimension', 1),(5, '$site_id', 'campaign_source', 5, 'action', 1, '$dimension',1),(6, '$site_id', 'customer_label', 6, 'action', 1, '$dimension',1),(7, '$site_id', 'product_id', 7, 'action', 1, '$dimension', 1),(8, '$site_id', 'coupon_id', 8, 'action', 1, '$dimension', 1),(9, '$site_id', 'product_name', 9, 'action', 1, '$dimension', 1),(10, '$site_id','coupon_name', 10, 'action', 1, '$dimension',1),(11, '$site_id', 'product_discount', 11, 'action', 1, '$dimension', 1),(12, '$site_id', 'rule_id', 12, 'action', 1, '$dimension', 1),(13, '$site_id', 'clicked_area', 13, 'action', 1, '$dimension', 1),(14, '$site_id', 'user_name', 1, 'visit', 1, '[]', 1),(15, '$site_id', 'user_email', 2, 'visit', 1, '[]', 1),(16, '$site_id', 'cart_product_id', 3, 'visit', 1, '[]', 1),(17, '$site_id', 'cart_varient_id', 4, 'visit', 1, '[]', 1),(18, '$site_id', 'cart_contains_1', 5, 'visit', 1, '[]', 1),(19, '$site_id', 'cart_contains_2', 6, 'visit', 1, '[]', 1),(20, '$site_id', 'cart_contains_3', 7, 'visit', 1, '[]', 1),(21, '$site_id', 'unique_action_id', 14, 'action', 1, '$dimension', 1)";
		
		$db->query($sql);
		return true;
		
        
    }
}

