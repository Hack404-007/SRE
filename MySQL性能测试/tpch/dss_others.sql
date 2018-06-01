use tpch;

alter table CUSTOMER	rename to customer ;
alter table LINEITEM	rename to lineitem ;
alter table NATION	rename to nation   ;
alter table ORDERS	rename to orders   ;
alter table PART	rename to part     ;
alter table PARTSUPP	rename to partsupp ;
alter table REGION	rename to region   ;
alter table SUPPLIER	rename to supplier ;

alter table lineitem
 ADD KEY `lineitem_k2` (`L_QUANTITY`,`L_PARTKEY`),
 ADD KEY `lineitem_k3` (`L_QUANTITY`,`L_SHIPMODE`,`L_SHIPINSTRUCT`),
 ADD KEY `lineitem_k4` (`L_PARTKEY`,`L_SUPPKEY`,`L_SHIPDATE`),
 ADD KEY `lineitem_k5` (`L_SHIPDATE`,`L_RETURNFLAG`,`L_LINESTATUS`),
 ADD KEY `lineitem_k6` (`L_SHIPDATE`,`L_DISCOUNT`,`L_QUANTITY`);

alter table part ADD KEY `part_k1` (`P_NAME`);

alter table supplier ADD  KEY `supplier_k1` (`S_SUPPKEY`,`S_NATIONKEY`,`S_NAME`);
