<?php
class Database{
    var $header;
    var $colname;
    var $rows;
    public function __construct() {
        $handle = fopen("Mobile_Food_Facility_Permit.csv", 'r');
        if (!$handle) {
            exit(2);
        }
        $this->colname = [];
        $this->rows = [];
        while (($data = fgetcsv($handle)) !== false) {
            if($this->header == null){
                for($i=0; $i<count($data); $i++){
                    $this->colname[ $data[$i] ] = $i;
                }
                $this->header = $data;
            }else{
                if(count($data) != count($this->header)){
                    exit(1);
                }
                array_push($this->rows, $data);
            }
        }
    }

    public function find($keyword){
        if( $keyword == "" ){
            return [];
        }
        $cols = ['Applicant', 'Address', 'FoodItems'];
        $rows = [];
        foreach($this->rows as $row){
            foreach($cols as $col){
                if( false !== strpos( strtolower($row[ $this->colname[ $col ] ]), strtolower($keyword) ) ){
                    array_push($rows, $this->to_hash( $row ));
                    break;
                }
            }
        }
        return $rows;
    }

    public function random_one() {
        $m = count($this->rows);
        return $this->to_hash( $this->rows[rand(0, $m-1)] );
    }

    public function to_hash($row){
        $h = [];
        foreach($this->colname as $col => $idx){
            $h[ $col ] = $row[$idx];
        }
        return $h;
    }
}