-- This code is used by changing the table name to suit all 4 municipalities



ALTER TABLE boston_neighborhoods
add column area_p numeric,
add column area_ind numeric,
add column area_trans numeric,
add column area_res numeric,
add column area_inst numeric,
add column area_rec numeric,
add column area_com numeric,
add column area_nat numeric,
add column area_os numeric,
add column area_ag numeric,
add column area_other numeric,
add column ludi numeric;

CREATE TABLE cos_nbhd_boston AS
SELECT ST_Intersection(t1.the_geom, t2.the_geom) AS the_geom,
t1.name, t1.n_hood, t1.area_p, t1.area_ind, t1.area_trans, t1.area_res, t1.area_inst, t1.area_rec, t1.area_com, t1.area_nat, t1.area_os, t1.area_ag, t1.area_other, t1.ludi, t2.zonecode1
FROM boston_neighborhoods as t1, land_use as t2
WHERE ST_Intersects(t1.the_geom, t2.the_geom)
ORDER BY t1.cartodb_id, t1.name, t2.zonecode1;

ALTER TABLE cos_nbhd_boston
ADD COLUMN area numeric;

UPDATE cos_nbhd_boston
SET area=ST_Area(the_geom::geography)/10^4;

UPDATE cos_nbhd_boston
SET area_p=0, area_ind=0, area_trans=0, area_res=0, area_inst=0, area_rec=0, area_com=0, area_nat=0, area_os=0, area_ag=0, area_other=0, ludi=0;

UPDATE boston_neighborhoods
SET area_p=0, area_ind=0, area_trans=0, area_res=0, area_inst=0, area_rec=0, area_com=0, area_nat=0, area_os=0, area_ag=0, area_other=0, ludi=0;

UPDATE cos_nbhd_boston
SET area_p=area
where zonecode1='Public Services';

UPDATE cos_nbhd_boston
SET area_ind=area
where zonecode1='Industrial';

UPDATE cos_nbhd_boston
SET area_trans=area
where zonecode1='Transportation';

UPDATE cos_nbhd_boston
SET area_res=area
where zonecode1='Residential';

UPDATE cos_nbhd_boston
SET area_inst=area
where zonecode1='Institutional';

UPDATE cos_nbhd_boston
SET area_rec=area
where zonecode1='Recreation';

UPDATE cos_nbhd_boston
SET area_com=area
where zonecode1='Business/Commercial';

UPDATE cos_nbhd_boston
SET area_nat=area
where zonecode1='Natural';

UPDATE cos_nbhd_boston
SET area_os=area
where zonecode1='Open Space';

UPDATE cos_nbhd_boston
SET area_ag=area
where zonecode1='Agriculture';

UPDATE cos_nbhd_boston
SET area_other=area
where zonecode1='Other';

CREATE TABLE cos_nb_boston AS
select name, n_hood, sum(area_p) as p_ha, sum(area_ind) as ind_ha, sum(area_trans) as trans_ha, sum(area_res) as res_ha, sum(area_inst) as inst_ha, sum(area_rec) as rec_ha, sum(area_com) as com_ha, sum(area_nat) as nat_ha, sum(area_os) as os_ha, sum(area_ag) as ag_ha, sum(area_other) as other_ha
FROM cos_nbhd_boston
GROUP BY name, n_hood;

UPDATE boston_neighborhoods AS t1
SET (area_p, area_ind, area_trans, area_res, area_inst, area_rec, area_com, area_nat, area_os, area_ag, area_other)=(
	SELECT t2.p_ha, t2.ind_ha, t2.trans_ha, t2.res_ha, t2.inst_ha, t2.rec_ha, t2.com_ha, t2.nat_ha, t2.os_ha, t2.ag_ha, t2.other_ha
	FROM cos_nb_boston as t2
	WHERE t1.name=t2.name
	ORDER BY t1.name);

ALTER TABLE boston_neighborhoods
ADD COLUMN area_ludi numeric;

UPDATE boston_neighborhoods
SET area_ludi = area_ind + area_trans + area_res + area_inst + area_com + area_ag + area_os;

UPDATE boston_neighborhoods
SET ludi = 1 - (ABS(area_ind/area_ludi - 0.1667) + ABS(area_trans/area_ludi - 0.1667) + ABS(area_res/area_ludi - 0.1667) + ABS(area_inst/area_ludi - 0.1667) + ABS(area_com/area_ludi - 0.1667) + ABS(area_nat/area_ludi - 0.1667) + ABS(area_os/area_ludi - 0.1667)) / 1.6667;
