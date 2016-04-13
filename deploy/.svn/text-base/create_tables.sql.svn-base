create table resource
(
    id int DEFAULT nextval ('id_seq') NOT NULL,
    userkey text NOT NULL,
    signature text,
    PRIMARY KEY(id)
);

create table resource_stage
(
    id int,
    userkey text UNIQUE NOT NULL,
    signature text,
    PRIMARY KEY (id)
);

create table descriptor_stage
(
    name varchar(255) NOT NULL,
    value text  NOT NULL,
    description text,
    type text,
    res_id int CONSTRAINT descriptor_stage_res_id_fkey REFERENCES resource_stage (id) ON DELETE CASCADE
);

create table triple_stage
(
  subject text,
  property text,
  object text
);

create table signature
(
    signature text,
    tabletag int,
    PRIMARY KEY(signature)
);

create table cachedquery 
(
    id int PRIMARY KEY, 
    query_string text, 
    hit_count int, 
    result_size int
);

create table cachedqueryresult 
(
    qid int REFERENCES cachedquery (id) ON DELETE CASCADE, 
    value text
);


