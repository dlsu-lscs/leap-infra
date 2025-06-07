-- production

select * from migrations;
select * from users;
select * from users order by name asc;
describe users;
select id, users.email, users.created_at from users;
describe events;

select * from events;

select count(*) from registrations;

select * from events where code = 'S1045';
select * from orgs;

-- hehe
select users.name, events.title, orgs.name, subthemes.short_desc
from users
join registrations on users.id = registrations.user_id
join events on events.id = registrations.event_id
join orgs on orgs.id = events.org_id
join subthemes on subthemes.id = events.subtheme_id;

-- check num of poeple registered based on interests
select subthemes.short_desc as interests, count(subthemes.short_desc) as num_people_interested
from users
join registrations on users.id = registrations.user_id
join events on events.id = registrations.event_id
join orgs on orgs.id = events.org_id
join subthemes on subthemes.id = events.subtheme_id
group by interests
order by num_people_interested desc;


-- count number of registrations given event id
select count(*) as num_registrations 
from events 
join registrations on registrations.event_id = events.id
where events.id = 8; 

-- select all who registered given event id
select users.id, users.email, events.id as event_id, events.title as event_title
from registrations 
join users on users.id = registrations.user_id
join events on events.id = registrations.event_id
where events.id = 8;


select id, name from users where email = 'candice_fernandez@dlsu.edu.ph';

-- - shana_haw@dlsu.edu.ph
-- - jasmine_guerrero@dlsu.edu.ph
-- - princess_caresse_maravillas@dlsu.edu.ph
-- - liriane_magsino@dlsu.edu.ph
-- - fredelyn_ang@dlsu.edu.ph

select * from events;

insert into registrations (user_id, event_id) values (561, 8);

select * from events;

select * from registrations;


-- grep event by title (also checks if it is in registrations table, and actual_registered_count)
select 
    events.id as event_id,
    events.title as event_title,
    subthemes.title as subtheme_title,
    events.code,
    events.max_slots,
    events.registered_slots,
    case 
    when exists (
        select 1
        from registrations
        where registrations.event_id = events.id
    ) then 'true' else 'false'
    end as is_in_registrations_table,
    events.gforms_url
from events 
join subthemes on events.subtheme_id = subthemes.id
where events.title like '%Song%';

select id as event_id, title as event_title, code, max_slots, registered_slots from events where code like '%S1053%';

-- simple check for slot updater (to check event id of what to update)
select id as event_id, title as event_title, code, max_slots, registered_slots from events where id = 73;
-- slot updater
update events set registered_slots = 30 where id = 73;
update events set max_slots = 60 where id = 10;
update events set max_slots = 60 where id = 73;

update events set registered_slots = 84 where id = 20;
update events set max_slots = 84 where id = 20;

-- check users who registered given event id
select 
    registrations.user_id, users.email, events.title as event_title
from registrations
join users on registrations.user_id = users.id
join events on registrations.event_id = events.id
where registrations.event_id = 50;

select * from users where id = 4450;

-- check actual register count recorded in registrations table 
-- - these are the count of users WHO logged in at least once on website to register to an event
-- - users not counted here: 
-- ----> users who haven't logged in to the website yet
-- ----> users who submitted gforms via direct url (without logging in to website)
-- ----> users who submitted gforms via direct url BEFORE logging in (meaning the created_at date is only after the registrations records of user)
--       ----> all registrations made before logging in once (to create a user record) is not counted here (neglected in database)
select 
    count(events.id) as num_registrations_in_db,
    events.id as event_id,
    events.code,
    events.title as event_title
from registrations
join events on registrations.event_id = events.id
group by events.id;

select users.id as user_id, users.email as user_email 
from users 
join registrations on users.id = registrations.user_id
where google_id is null;

select users.id as user_id, google_id, email, name

select users.id as user_id, google_id, email, name
from registrations
left join users on users.id = registrations.user_id
left join events on events.id = registrations.event_id
where events.id = 29
and users.email in ('ashley_vinuya@dlsu.edu.ph', 'ezra_lexandra_lim@dlsu.edu.ph', 'sean_kendrick_t_king@dlsu.edu.ph', 'jessica_eunice_s_hong@dlsu.edu.ph', 'sam_poon@dlsu.edu.ph', 'mac_uy@dlsu.edu.ph', 'alyssa_raine_anggaeid@dlsu.edu.ph', 'lianne_lim@dlsu.edu.ph', 'helenna_delacerna@dlsu.edu.ph', 'kenzo_rei_lo@dlsu.edu.ph', 'caitlin_althea_delasalas@dlsu.edu.ph', 'sean_benedict_ang@dlsu.edu.ph', 'joseph_yangchoon@dlsu.edu.ph', 'shawn_dacalus@dlsu.edu.ph', 'joshua_legaspi@dlsu.edu.ph', 'josh_chan@dlsu.edu.ph', 'samantha_pineda@dlsu.edu.ph', 'jose_angelo_rubiano@dlsu.edu.ph', 'michael_aringo@dlsu.edu.ph', 'mika_diaz@dlsu.edu.ph', 'miko_diaz@dlsu.edu.ph', 'ka_cai@dlsu.edu.ph', 'jason_duallo@dlsu.edu.ph', 'miguel_navalta@dlsu.edu.ph', 'nicole_jia_shi@dlsu.edu.ph', 'lauren_vengco@dlsu.edu.ph', 'paolo_haboc@dlsu.edu.ph', 'miguel_flores@dlsu.edu.ph', 'enzo_rafael_chan@dlsu.edu.ph', 'louisa_garcia@dlsu.edu.ph', 'mikayla_chua@dlsu.edu.ph', 'reever_lacson@dlsu.edu.ph', 'andrea_li_santos@dlsu.edu.ph', 'lorenzo_ermita@dlsu.edu.ph', 'adrien_dones@dlsu.edu.ph', 'queenie_mae_salao@dlsu.edu.ph', 'thea_delacruz@dlsu.edu.ph', 'brylle_talaban@dlsu.edu.ph', 'amienz_arago@dlsu.edu.ph', 'sidney_chan@dlsu.edu.ph', 'aly_valdez@dlsu.edu.ph', 'davina_garcia@dlsu.edu.ph', 'kisha_punsalan@dlsu.edu.ph', 'zigmund_mickael_samarista@dlsu.edu.ph', 'on_chen@dlsu.edu.ph', 'cayla_yao@dlsu.edu.ph', 'luisa_pando@dlsu.edu.ph', 'allana_madlangbayan@dlsu.edu.ph', 'schen_baguio@dlsu.edu.ph', 'mikaiah_dayne_tan@dlsu.edu.ph', 'angelo_li@dlsu.edu.ph', 'mathew_benavidez@dlsu.edu.ph', 'timothy_benavidez@dlsu.edu.ph', 'ana_victoria_angat@dlsu.edu.ph', 'beyonce_estavillo@dlsu.edu.ph', 'monjohn_delacruz@dlsu.edu.ph', 'nancy_lu@dlsu.edu.ph', 'james_ang@dlsu.edu.ph', 'nathan_zhang@dlsu.edu.ph', 'aliyah_sumalisid@dlsu.edu.ph', 'alexandra_manlusoc@dlsu.edu.ph', 'celine_wang@dlsu.edu.ph', 'angeline_r_li@dlsu.edu.ph', 'cuthbert_ong@dlsu.edu.ph', 'clarisse_ke@dlsu.edu.ph', 'jeremy_cu@dlsu.edu.ph', 'james_s_lim@dlsu.edu.ph', 'erwin_alfonso@dlsu.edu.ph', 'elbert_justen_pua@dlsu.edu.ph', 'anthony_andrei_c_tan@dlsu.edu.ph', 'daniel_costales@dlsu.edu.ph', 'kendric_see@dlsu.edu.ph', 'wilhelm_lee@dlsu.edu.ph', 'hershel_judd_lee@dlsu.edu.ph', 'reo_yiu@dlsu.edu.ph', 'joshua_christian_yap@dlsu.edu.ph', 'ron_evangelista@dlsu.edu.ph', 'isabelle_ngo@dlsu.edu.ph', 'dave_edward_go@dlsu.edu.ph', 'jet_sy@dlsu.edu.ph', 'kyle_lester_ang@dlsu.edu.ph', 'anton_bagares@dlsu.edu.ph', 'almira_deaustria@dlsu.edu.ph', 'wesley_chung@dlsu.edu.ph', 'raphael_payar@dlsu.edu.ph', 'lance_elric_dy@dlsu.edu.ph', 'jaime_gabriel_pineda@dlsu.edu.ph', 'alvyna_deaustria@dlsu.edu.ph', 'annika_tiu@dlsu.edu.ph', 'angela_madrigal@dlsu.edu.ph', 'justin_wilhelm_yang@dlsu.edu.ph', 'jasper_ivan_zhao@dlsu.edu.ph', 'paolo_manlongat@dlsu.edu.ph', 'sheena_chan@dlsu.edu.ph', 'gino_ong@dlsu.edu.ph', 'adrianna_chua@dlsu.edu.ph', 'vilareza_qiu@dlsu.edu.ph', 'adrian_villador@dlsu.edu.ph', 'kian_chayce_tan@dlsu.edu.ph', 'lawrence_allen_f_co@dlsu.edu.ph', 'juano_arthur_donaire@dlsu.edu.ph', 'dave_aldwin_bolima@dlsu.edu.ph', 'shane_johann_lee@dlsu.edu.ph', 'emily_yu@dlsu.edu.ph', 'matthew_gregory_que@dlsu.edu.ph', 'kian_cedric_ang@dlsu.edu.ph', 'maiko_angelo_alcazar@dlsu.edu.ph', 'charles_eivan_uy@dlsu.edu.ph', 'steven_chua@dlsu.edu.ph', 'pietro_buenaventura@dlsu.edu.ph', 'justin_cenizal@dlsu.edu.ph', 'alisha_chua@dlsu.edu.ph', 'jenerlyn_gan@dlsu.edu.ph', 'jocelyn_gan@dlsu.edu.ph', 'quinn_cai@dlsu.edu.ph', 'mikolo_chen@dlsu.edu.ph', 'renz_chen@dlsu.edu.ph', 'rende_yeungakaedwinyu@dlsu.edu.ph', 'christian_joseph_uy@dlsu.edu.ph', 'andre_cai@dlsu.edu.ph', 'ria_madrigal@dlsu.edu.ph', 'tracey_karylle_lim@dlsu.edu.ph', 'chrisha_anne_gaw@dlsu.edu.ph', 'ingrid_quizon@dlsu.edu.ph', 'juliane_co@dlsu.edu.ph', 'raphael_matthew_lim@dlsu.edu.ph', 'mikhail_stefan_uy@dlsu.edu.ph', 'youshun_xu@dlsu.edu.ph', 'alec_johann_chua@dlsu.edu.ph', 'miguel_lance_ang@dlsu.edu.ph', 'lyka_porras@dlsu.edu.ph', 'michael_ramirez@dlsu.edu.ph', 'yin_uy@dlsu.edu.ph', 'sean_kevin_pacheco@dlsu.edu.ph', 'clarizze_lu@dlsu.edu.ph', 'eunice_lao@dlsu.edu.ph', 'benjamin_chen@dlsu.edu.ph', 'christine_esther_tan@dlsu.edu.ph', 'nelson_darwin_lii@dlsu.edu.ph', 'yosh_sy@dlsu.edu.ph', 'kimberly_hong@dlsu.edu.ph', 'tang_tang@dlsu.edu.ph', 'stacey_que@dlsu.edu.ph', 'jarred_valencia@dlsu.edu.ph', 'angela_cua@dlsu.edu.ph', 'john_joseph_to@dlsu.edu.ph', 'chloe_lyca_ang@dlsu.edu.ph', 'bianca_alexandra_yiu@dlsu.edu.ph', 'karise_tang@dlsu.edu.ph', 'ketty_sy@dlsu.edu.ph', 'andrei_zachary_lim@dlsu.edu.ph', 'beatrice_santos@dlsu.edu.ph', 'pierce_zachary_hokia@dlsu.edu.ph', 'gian_laolao@dlsu.edu.ph', 'mark_edison_jim@dlsu.edu.ph', 'ced_yu@dlsu.edu.ph', 'denise_chelsea_li@dlsu.edu.ph', 'mariliz_tan@dlsu.edu.ph', 'timmy_yap@dlsu.edu.ph', 'liana_padua@dlsu.edu.ph', 'theodore_suatengco@dlsu.edu.ph', 'jacob_austin_t_chua@dlsu.edu.ph', 'letitia_pahati@dlsu.edu.ph', 'john_joaquin_tioco@dlsu.edu.ph', 'joshua_luigi_cestina@dlsu.edu.ph', 'vladimir_tang@dlsu.edu.ph', 'ma_alexandria_apostol@dlsu.edu.ph', 'david_gochuico@dlsu.edu.ph', 'carl_justin_chiam@dlsu.edu.ph', 'tricia_hui@dlsu.edu.ph', 'jasmine_reese_yu@dlsu.edu.ph', 'lourdes_vasquez@dlsu.edu.ph', 'venice_cua@dlsu.edu.ph', 'adrian_tanchua@dlsu.edu.ph', 'sabrina_macaraya@dlsu.edu.ph', 'ethen_gobaco@dlsu.edu.ph', 'shereen_danielle_haduca@dlsu.edu.ph', 'hans_meneses@dlsu.edu.ph', 'jennalyn_dee@dlsu.edu.ph', 'lalaine_co@dlsu.edu.ph', 'lance_ulryck_corpuz@dlsu.edu.ph', 'tim_olvina@dlsu.edu.ph', 'louisse_gonzales@dlsu.edu.ph', 'eldridge_ty@dlsu.edu.ph', 'anika_caranto@dlsu.edu.ph', 'reanne_abigan@dlsu.edu.ph', 'anton_borromeo@dlsu.edu.ph', 'janray_dulatre@dlsu.edu.ph', 'ayana_paa@dlsu.edu.ph', 'razel_wang@dlsu.edu.ph', 'razel_michelle_wang@dlsu.edu.ph', 'xavier_quinones@dlsu.edu.ph', 'samantha_czkyhna_macatangay@dlsu.edu.ph', 'mikaela_lao@dlsu.edu.ph', 'keziah_sy@dlsu.edu.ph', 'jermaine_ong@dlsu.edu.ph', 'kayi_go@dlsu.edu.ph', 'marc_roosty_co@dlsu.edu.ph', 'hervyn_y_co@dlsu.edu.ph', 'ezekiel_libao@dlsu.edu.ph', 'journey_dy@dlsu.edu.ph', 'klint_ching@dlsu.edu.ph', 'irish_ty@dlsu.edu.ph', 'aaliyah_gan@dlsu.edu.ph', 'edrich_samuel_tan@dlsu.edu.ph', 'belle_elizabeth_tan@dlsu.edu.ph', 'christine_palomado@dlsu.edu.ph', 'christine_wingkee@dlsu.edu.ph', 'angeline_pua@dlsu.edu.ph', 'yao_rong_wu@dlsu.edu.ph', 'hebron_tan@dlsu.edu.ph', 'lance_angelo_ong@dlsu.edu.ph', 'clarence_so@dlsu.edu.ph', 'nathan_angping@dlsu.edu.ph', 'dave_reyes@dlsu.edu.ph', 'karl_nathan_lim@dlsu.edu.ph', 'adrian_louis_chua@dlsu.edu.ph', 'alyssa_nolasco@dlsu.edu.ph', 'maxine_ang@dlsu.edu.ph', 'julia_wenceslao@dlsu.edu.ph', 'ma_cielo_nicdao@dlsu.edu.ph', 'jarrell_ang@dlsu.edu.ph', 'francia_palatino@dlsu.edu.ph', 'dreizen_malyx_ty@dlsu.edu.ph', 'thania_calderon@dlsu.edu.ph', 'clair_lota@dlsu.edu.ph', 'wes_sy@dlsu.edu.ph', 'frodel_pascua@dlsu.edu.ph', 'janella_padilla@dlsu.edu.ph', 'willy_liu@dlsu.edu.ph', 'jamie_ross_padilla@dlsu.edu.ph', 'andrew_kho@dlsu.edu.ph', 'patricia_ignacio@dlsu.edu.ph', 'kim_russel_llanto@dlsu.edu.ph', 'shao_wang@dlsu.edu.ph', 'kayzelle_reyes@dlsu.edu.ph', 'eavie_ong@dlsu.edu.ph', 'dondon_jolito_sy@dlsu.edu.ph', 'andre_elijah_techico@dlsu.edu.ph', 'jason_pamati-an@dlsu.edu.ph', 'jeremy_james_tan@dlsu.edu.ph', 'alwyn_stefan_chang@dlsu.edu.ph', 'sidney_co@dlsu.edu.ph', 'ericka_yao@dlsu.edu.ph', 'bianca_louise_malizon@dlsu.edu.ph', 'ralf_see@dlsu.edu.ph', 'rexanne_tan@dlsu.edu.ph', 'mike_bernal@dlsu.edu.ph', 'shey_tan@dlsu.edu.ph', 'nica_sia@dlsu.edu.ph', 'milford_emerson_yao@dlsu.edu.ph', 'julianne_kirsten_tan@dlsu.edu.ph', 'kobe_buenconsejo@dlsu.edu.ph', 'grizelle_nohay@dlsu.edu.ph', 'justin_foxas@dlsu.edu.ph', 'orrin_landon_uy@dlsu.edu.ph', 'josef_antonio@dlsu.edu.ph', 'erika_see@dlsu.edu.ph', 'josfer_chuason@dlsu.edu.ph', 'maureen_amariah_b_canlas@dlsu.edu.ph', 'zelby_baluan@dlsu.edu.ph', 'byron_hung@dlsu.edu.ph', 'francesca_danica_reynoso@dlsu.edu.ph', 'erica_joy_ong@dlsu.edu.ph', 'kate_ko@dlsu.edu.ph', 'ma_tricia_ocho@dlsu.edu.ph', 'rob_simon_casao@dlsu.edu.ph');

select * from users where email in ('ashley_vinuya@dlsu.edu.ph', 'ezra_lexandra_lim@dlsu.edu.ph', 'sean_kendrick_t_king@dlsu.edu.ph', 'jessica_eunice_s_hong@dlsu.edu.ph', 'sam_poon@dlsu.edu.ph', 'mac_uy@dlsu.edu.ph', 'alyssa_raine_anggaeid@dlsu.edu.ph', 'lianne_lim@dlsu.edu.ph', 'helenna_delacerna@dlsu.edu.ph', 'kenzo_rei_lo@dlsu.edu.ph', 'caitlin_althea_delasalas@dlsu.edu.ph', 'sean_benedict_ang@dlsu.edu.ph', 'joseph_yangchoon@dlsu.edu.ph', 'shawn_dacalus@dlsu.edu.ph', 'joshua_legaspi@dlsu.edu.ph', 'josh_chan@dlsu.edu.ph', 'samantha_pineda@dlsu.edu.ph', 'jose_angelo_rubiano@dlsu.edu.ph', 'michael_aringo@dlsu.edu.ph', 'mika_diaz@dlsu.edu.ph', 'miko_diaz@dlsu.edu.ph', 'ka_cai@dlsu.edu.ph', 'jason_duallo@dlsu.edu.ph', 'miguel_navalta@dlsu.edu.ph', 'nicole_jia_shi@dlsu.edu.ph', 'lauren_vengco@dlsu.edu.ph', 'paolo_haboc@dlsu.edu.ph', 'miguel_flores@dlsu.edu.ph', 'enzo_rafael_chan@dlsu.edu.ph', 'louisa_garcia@dlsu.edu.ph', 'mikayla_chua@dlsu.edu.ph', 'reever_lacson@dlsu.edu.ph', 'andrea_li_santos@dlsu.edu.ph', 'lorenzo_ermita@dlsu.edu.ph', 'adrien_dones@dlsu.edu.ph', 'queenie_mae_salao@dlsu.edu.ph', 'thea_delacruz@dlsu.edu.ph', 'brylle_talaban@dlsu.edu.ph', 'amienz_arago@dlsu.edu.ph', 'sidney_chan@dlsu.edu.ph', 'aly_valdez@dlsu.edu.ph', 'davina_garcia@dlsu.edu.ph', 'kisha_punsalan@dlsu.edu.ph', 'zigmund_mickael_samarista@dlsu.edu.ph', 'on_chen@dlsu.edu.ph', 'cayla_yao@dlsu.edu.ph', 'luisa_pando@dlsu.edu.ph', 'allana_madlangbayan@dlsu.edu.ph', 'schen_baguio@dlsu.edu.ph', 'mikaiah_dayne_tan@dlsu.edu.ph', 'angelo_li@dlsu.edu.ph', 'mathew_benavidez@dlsu.edu.ph', 'timothy_benavidez@dlsu.edu.ph', 'ana_victoria_angat@dlsu.edu.ph', 'beyonce_estavillo@dlsu.edu.ph', 'monjohn_delacruz@dlsu.edu.ph', 'nancy_lu@dlsu.edu.ph', 'james_ang@dlsu.edu.ph', 'nathan_zhang@dlsu.edu.ph', 'aliyah_sumalisid@dlsu.edu.ph', 'alexandra_manlusoc@dlsu.edu.ph', 'celine_wang@dlsu.edu.ph', 'angeline_r_li@dlsu.edu.ph', 'cuthbert_ong@dlsu.edu.ph', 'clarisse_ke@dlsu.edu.ph', 'jeremy_cu@dlsu.edu.ph', 'james_s_lim@dlsu.edu.ph', 'erwin_alfonso@dlsu.edu.ph', 'elbert_justen_pua@dlsu.edu.ph', 'anthony_andrei_c_tan@dlsu.edu.ph', 'daniel_costales@dlsu.edu.ph', 'kendric_see@dlsu.edu.ph', 'wilhelm_lee@dlsu.edu.ph', 'hershel_judd_lee@dlsu.edu.ph', 'reo_yiu@dlsu.edu.ph', 'joshua_christian_yap@dlsu.edu.ph', 'ron_evangelista@dlsu.edu.ph', 'isabelle_ngo@dlsu.edu.ph', 'dave_edward_go@dlsu.edu.ph', 'jet_sy@dlsu.edu.ph', 'kyle_lester_ang@dlsu.edu.ph', 'anton_bagares@dlsu.edu.ph', 'almira_deaustria@dlsu.edu.ph', 'wesley_chung@dlsu.edu.ph', 'raphael_payar@dlsu.edu.ph', 'lance_elric_dy@dlsu.edu.ph', 'jaime_gabriel_pineda@dlsu.edu.ph', 'alvyna_deaustria@dlsu.edu.ph', 'annika_tiu@dlsu.edu.ph', 'angela_madrigal@dlsu.edu.ph', 'justin_wilhelm_yang@dlsu.edu.ph', 'jasper_ivan_zhao@dlsu.edu.ph', 'paolo_manlongat@dlsu.edu.ph', 'sheena_chan@dlsu.edu.ph', 'gino_ong@dlsu.edu.ph', 'adrianna_chua@dlsu.edu.ph', 'vilareza_qiu@dlsu.edu.ph', 'adrian_villador@dlsu.edu.ph', 'kian_chayce_tan@dlsu.edu.ph', 'lawrence_allen_f_co@dlsu.edu.ph', 'juano_arthur_donaire@dlsu.edu.ph', 'dave_aldwin_bolima@dlsu.edu.ph', 'shane_johann_lee@dlsu.edu.ph', 'emily_yu@dlsu.edu.ph', 'matthew_gregory_que@dlsu.edu.ph', 'kian_cedric_ang@dlsu.edu.ph', 'maiko_angelo_alcazar@dlsu.edu.ph', 'charles_eivan_uy@dlsu.edu.ph', 'steven_chua@dlsu.edu.ph', 'pietro_buenaventura@dlsu.edu.ph', 'justin_cenizal@dlsu.edu.ph', 'alisha_chua@dlsu.edu.ph', 'jenerlyn_gan@dlsu.edu.ph', 'jocelyn_gan@dlsu.edu.ph', 'quinn_cai@dlsu.edu.ph', 'mikolo_chen@dlsu.edu.ph', 'renz_chen@dlsu.edu.ph', 'rende_yeungakaedwinyu@dlsu.edu.ph', 'christian_joseph_uy@dlsu.edu.ph', 'andre_cai@dlsu.edu.ph', 'ria_madrigal@dlsu.edu.ph', 'tracey_karylle_lim@dlsu.edu.ph', 'chrisha_anne_gaw@dlsu.edu.ph', 'ingrid_quizon@dlsu.edu.ph', 'juliane_co@dlsu.edu.ph', 'raphael_matthew_lim@dlsu.edu.ph', 'mikhail_stefan_uy@dlsu.edu.ph', 'youshun_xu@dlsu.edu.ph', 'alec_johann_chua@dlsu.edu.ph', 'miguel_lance_ang@dlsu.edu.ph', 'lyka_porras@dlsu.edu.ph', 'michael_ramirez@dlsu.edu.ph', 'yin_uy@dlsu.edu.ph', 'sean_kevin_pacheco@dlsu.edu.ph', 'clarizze_lu@dlsu.edu.ph', 'eunice_lao@dlsu.edu.ph', 'benjamin_chen@dlsu.edu.ph', 'christine_esther_tan@dlsu.edu.ph', 'nelson_darwin_lii@dlsu.edu.ph', 'yosh_sy@dlsu.edu.ph', 'kimberly_hong@dlsu.edu.ph', 'tang_tang@dlsu.edu.ph', 'stacey_que@dlsu.edu.ph', 'jarred_valencia@dlsu.edu.ph', 'angela_cua@dlsu.edu.ph', 'john_joseph_to@dlsu.edu.ph', 'chloe_lyca_ang@dlsu.edu.ph', 'bianca_alexandra_yiu@dlsu.edu.ph', 'karise_tang@dlsu.edu.ph', 'ketty_sy@dlsu.edu.ph', 'andrei_zachary_lim@dlsu.edu.ph', 'beatrice_santos@dlsu.edu.ph', 'pierce_zachary_hokia@dlsu.edu.ph', 'gian_laolao@dlsu.edu.ph', 'mark_edison_jim@dlsu.edu.ph', 'ced_yu@dlsu.edu.ph', 'denise_chelsea_li@dlsu.edu.ph', 'mariliz_tan@dlsu.edu.ph', 'timmy_yap@dlsu.edu.ph', 'liana_padua@dlsu.edu.ph', 'theodore_suatengco@dlsu.edu.ph', 'jacob_austin_t_chua@dlsu.edu.ph', 'letitia_pahati@dlsu.edu.ph', 'john_joaquin_tioco@dlsu.edu.ph', 'joshua_luigi_cestina@dlsu.edu.ph', 'vladimir_tang@dlsu.edu.ph', 'ma_alexandria_apostol@dlsu.edu.ph', 'david_gochuico@dlsu.edu.ph', 'carl_justin_chiam@dlsu.edu.ph', 'tricia_hui@dlsu.edu.ph', 'jasmine_reese_yu@dlsu.edu.ph', 'lourdes_vasquez@dlsu.edu.ph', 'venice_cua@dlsu.edu.ph', 'adrian_tanchua@dlsu.edu.ph', 'sabrina_macaraya@dlsu.edu.ph', 'ethen_gobaco@dlsu.edu.ph', 'shereen_danielle_haduca@dlsu.edu.ph', 'hans_meneses@dlsu.edu.ph', 'jennalyn_dee@dlsu.edu.ph', 'lalaine_co@dlsu.edu.ph', 'lance_ulryck_corpuz@dlsu.edu.ph', 'tim_olvina@dlsu.edu.ph', 'louisse_gonzales@dlsu.edu.ph', 'eldridge_ty@dlsu.edu.ph', 'anika_caranto@dlsu.edu.ph', 'reanne_abigan@dlsu.edu.ph', 'anton_borromeo@dlsu.edu.ph', 'janray_dulatre@dlsu.edu.ph', 'ayana_paa@dlsu.edu.ph', 'razel_wang@dlsu.edu.ph', 'razel_michelle_wang@dlsu.edu.ph', 'xavier_quinones@dlsu.edu.ph', 'samantha_czkyhna_macatangay@dlsu.edu.ph', 'mikaela_lao@dlsu.edu.ph', 'keziah_sy@dlsu.edu.ph', 'jermaine_ong@dlsu.edu.ph', 'kayi_go@dlsu.edu.ph', 'marc_roosty_co@dlsu.edu.ph', 'hervyn_y_co@dlsu.edu.ph', 'ezekiel_libao@dlsu.edu.ph', 'journey_dy@dlsu.edu.ph', 'klint_ching@dlsu.edu.ph', 'irish_ty@dlsu.edu.ph', 'aaliyah_gan@dlsu.edu.ph', 'edrich_samuel_tan@dlsu.edu.ph', 'belle_elizabeth_tan@dlsu.edu.ph', 'christine_palomado@dlsu.edu.ph', 'christine_wingkee@dlsu.edu.ph', 'angeline_pua@dlsu.edu.ph', 'yao_rong_wu@dlsu.edu.ph', 'hebron_tan@dlsu.edu.ph', 'lance_angelo_ong@dlsu.edu.ph', 'clarence_so@dlsu.edu.ph', 'nathan_angping@dlsu.edu.ph', 'dave_reyes@dlsu.edu.ph', 'karl_nathan_lim@dlsu.edu.ph', 'adrian_louis_chua@dlsu.edu.ph', 'alyssa_nolasco@dlsu.edu.ph', 'maxine_ang@dlsu.edu.ph', 'julia_wenceslao@dlsu.edu.ph', 'ma_cielo_nicdao@dlsu.edu.ph', 'jarrell_ang@dlsu.edu.ph', 'francia_palatino@dlsu.edu.ph', 'dreizen_malyx_ty@dlsu.edu.ph', 'thania_calderon@dlsu.edu.ph', 'clair_lota@dlsu.edu.ph', 'wes_sy@dlsu.edu.ph', 'frodel_pascua@dlsu.edu.ph', 'janella_padilla@dlsu.edu.ph', 'willy_liu@dlsu.edu.ph', 'jamie_ross_padilla@dlsu.edu.ph', 'andrew_kho@dlsu.edu.ph', 'patricia_ignacio@dlsu.edu.ph', 'kim_russel_llanto@dlsu.edu.ph', 'shao_wang@dlsu.edu.ph', 'kayzelle_reyes@dlsu.edu.ph', 'eavie_ong@dlsu.edu.ph', 'dondon_jolito_sy@dlsu.edu.ph', 'andre_elijah_techico@dlsu.edu.ph', 'jason_pamati-an@dlsu.edu.ph', 'jeremy_james_tan@dlsu.edu.ph', 'alwyn_stefan_chang@dlsu.edu.ph', 'sidney_co@dlsu.edu.ph', 'ericka_yao@dlsu.edu.ph', 'bianca_louise_malizon@dlsu.edu.ph', 'ralf_see@dlsu.edu.ph', 'rexanne_tan@dlsu.edu.ph', 'mike_bernal@dlsu.edu.ph', 'shey_tan@dlsu.edu.ph', 'nica_sia@dlsu.edu.ph', 'milford_emerson_yao@dlsu.edu.ph', 'julianne_kirsten_tan@dlsu.edu.ph', 'kobe_buenconsejo@dlsu.edu.ph', 'grizelle_nohay@dlsu.edu.ph', 'justin_foxas@dlsu.edu.ph', 'orrin_landon_uy@dlsu.edu.ph', 'josef_antonio@dlsu.edu.ph', 'erika_see@dlsu.edu.ph', 'josfer_chuason@dlsu.edu.ph', 'maureen_amariah_b_canlas@dlsu.edu.ph', 'zelby_baluan@dlsu.edu.ph', 'byron_hung@dlsu.edu.ph', 'francesca_danica_reynoso@dlsu.edu.ph', 'erica_joy_ong@dlsu.edu.ph', 'kate_ko@dlsu.edu.ph', 'ma_tricia_ocho@dlsu.edu.ph', 'rob_simon_casao@dlsu.edu.ph');

select count('ashley_vinuya@dlsu.edu.ph', 'ezra_lexandra_lim@dlsu.edu.ph', 'sean_kendrick_t_king@dlsu.edu.ph', 'jessica_eunice_s_hong@dlsu.edu.ph', 'sam_poon@dlsu.edu.ph', 'mac_uy@dlsu.edu.ph', 'alyssa_raine_anggaeid@dlsu.edu.ph', 'lianne_lim@dlsu.edu.ph', 'helenna_delacerna@dlsu.edu.ph', 'kenzo_rei_lo@dlsu.edu.ph', 'caitlin_althea_delasalas@dlsu.edu.ph', 'sean_benedict_ang@dlsu.edu.ph', 'joseph_yangchoon@dlsu.edu.ph', 'shawn_dacalus@dlsu.edu.ph', 'joshua_legaspi@dlsu.edu.ph', 'josh_chan@dlsu.edu.ph', 'samantha_pineda@dlsu.edu.ph', 'jose_angelo_rubiano@dlsu.edu.ph', 'michael_aringo@dlsu.edu.ph', 'mika_diaz@dlsu.edu.ph', 'miko_diaz@dlsu.edu.ph', 'ka_cai@dlsu.edu.ph', 'jason_duallo@dlsu.edu.ph', 'miguel_navalta@dlsu.edu.ph', 'nicole_jia_shi@dlsu.edu.ph', 'lauren_vengco@dlsu.edu.ph', 'paolo_haboc@dlsu.edu.ph', 'miguel_flores@dlsu.edu.ph', 'enzo_rafael_chan@dlsu.edu.ph', 'louisa_garcia@dlsu.edu.ph', 'mikayla_chua@dlsu.edu.ph', 'reever_lacson@dlsu.edu.ph', 'andrea_li_santos@dlsu.edu.ph', 'lorenzo_ermita@dlsu.edu.ph', 'adrien_dones@dlsu.edu.ph', 'queenie_mae_salao@dlsu.edu.ph', 'thea_delacruz@dlsu.edu.ph', 'brylle_talaban@dlsu.edu.ph', 'amienz_arago@dlsu.edu.ph', 'sidney_chan@dlsu.edu.ph', 'aly_valdez@dlsu.edu.ph', 'davina_garcia@dlsu.edu.ph', 'kisha_punsalan@dlsu.edu.ph', 'zigmund_mickael_samarista@dlsu.edu.ph', 'on_chen@dlsu.edu.ph', 'cayla_yao@dlsu.edu.ph', 'luisa_pando@dlsu.edu.ph', 'allana_madlangbayan@dlsu.edu.ph', 'schen_baguio@dlsu.edu.ph', 'mikaiah_dayne_tan@dlsu.edu.ph', 'angelo_li@dlsu.edu.ph', 'mathew_benavidez@dlsu.edu.ph', 'timothy_benavidez@dlsu.edu.ph', 'ana_victoria_angat@dlsu.edu.ph', 'beyonce_estavillo@dlsu.edu.ph', 'monjohn_delacruz@dlsu.edu.ph', 'nancy_lu@dlsu.edu.ph', 'james_ang@dlsu.edu.ph', 'nathan_zhang@dlsu.edu.ph', 'aliyah_sumalisid@dlsu.edu.ph', 'alexandra_manlusoc@dlsu.edu.ph', 'celine_wang@dlsu.edu.ph', 'angeline_r_li@dlsu.edu.ph', 'cuthbert_ong@dlsu.edu.ph', 'clarisse_ke@dlsu.edu.ph', 'jeremy_cu@dlsu.edu.ph', 'james_s_lim@dlsu.edu.ph', 'erwin_alfonso@dlsu.edu.ph', 'elbert_justen_pua@dlsu.edu.ph', 'anthony_andrei_c_tan@dlsu.edu.ph', 'daniel_costales@dlsu.edu.ph', 'kendric_see@dlsu.edu.ph', 'wilhelm_lee@dlsu.edu.ph', 'hershel_judd_lee@dlsu.edu.ph', 'reo_yiu@dlsu.edu.ph', 'joshua_christian_yap@dlsu.edu.ph', 'ron_evangelista@dlsu.edu.ph', 'isabelle_ngo@dlsu.edu.ph', 'dave_edward_go@dlsu.edu.ph', 'jet_sy@dlsu.edu.ph', 'kyle_lester_ang@dlsu.edu.ph', 'anton_bagares@dlsu.edu.ph', 'almira_deaustria@dlsu.edu.ph', 'wesley_chung@dlsu.edu.ph', 'raphael_payar@dlsu.edu.ph', 'lance_elric_dy@dlsu.edu.ph', 'jaime_gabriel_pineda@dlsu.edu.ph', 'alvyna_deaustria@dlsu.edu.ph', 'annika_tiu@dlsu.edu.ph', 'angela_madrigal@dlsu.edu.ph', 'justin_wilhelm_yang@dlsu.edu.ph', 'jasper_ivan_zhao@dlsu.edu.ph', 'paolo_manlongat@dlsu.edu.ph', 'sheena_chan@dlsu.edu.ph', 'gino_ong@dlsu.edu.ph', 'adrianna_chua@dlsu.edu.ph', 'vilareza_qiu@dlsu.edu.ph', 'adrian_villador@dlsu.edu.ph', 'kian_chayce_tan@dlsu.edu.ph', 'lawrence_allen_f_co@dlsu.edu.ph', 'juano_arthur_donaire@dlsu.edu.ph', 'dave_aldwin_bolima@dlsu.edu.ph', 'shane_johann_lee@dlsu.edu.ph', 'emily_yu@dlsu.edu.ph', 'matthew_gregory_que@dlsu.edu.ph', 'kian_cedric_ang@dlsu.edu.ph', 'maiko_angelo_alcazar@dlsu.edu.ph', 'charles_eivan_uy@dlsu.edu.ph', 'steven_chua@dlsu.edu.ph', 'pietro_buenaventura@dlsu.edu.ph', 'justin_cenizal@dlsu.edu.ph', 'alisha_chua@dlsu.edu.ph', 'jenerlyn_gan@dlsu.edu.ph', 'jocelyn_gan@dlsu.edu.ph', 'quinn_cai@dlsu.edu.ph', 'mikolo_chen@dlsu.edu.ph', 'renz_chen@dlsu.edu.ph', 'rende_yeungakaedwinyu@dlsu.edu.ph', 'christian_joseph_uy@dlsu.edu.ph', 'andre_cai@dlsu.edu.ph', 'ria_madrigal@dlsu.edu.ph', 'tracey_karylle_lim@dlsu.edu.ph', 'chrisha_anne_gaw@dlsu.edu.ph', 'ingrid_quizon@dlsu.edu.ph', 'juliane_co@dlsu.edu.ph', 'raphael_matthew_lim@dlsu.edu.ph', 'mikhail_stefan_uy@dlsu.edu.ph', 'youshun_xu@dlsu.edu.ph', 'alec_johann_chua@dlsu.edu.ph', 'miguel_lance_ang@dlsu.edu.ph', 'lyka_porras@dlsu.edu.ph', 'michael_ramirez@dlsu.edu.ph', 'yin_uy@dlsu.edu.ph', 'sean_kevin_pacheco@dlsu.edu.ph', 'clarizze_lu@dlsu.edu.ph', 'eunice_lao@dlsu.edu.ph', 'benjamin_chen@dlsu.edu.ph', 'christine_esther_tan@dlsu.edu.ph', 'nelson_darwin_lii@dlsu.edu.ph', 'yosh_sy@dlsu.edu.ph', 'kimberly_hong@dlsu.edu.ph', 'tang_tang@dlsu.edu.ph', 'stacey_que@dlsu.edu.ph', 'jarred_valencia@dlsu.edu.ph', 'angela_cua@dlsu.edu.ph', 'john_joseph_to@dlsu.edu.ph', 'chloe_lyca_ang@dlsu.edu.ph', 'bianca_alexandra_yiu@dlsu.edu.ph', 'karise_tang@dlsu.edu.ph', 'ketty_sy@dlsu.edu.ph', 'andrei_zachary_lim@dlsu.edu.ph', 'beatrice_santos@dlsu.edu.ph', 'pierce_zachary_hokia@dlsu.edu.ph', 'gian_laolao@dlsu.edu.ph', 'mark_edison_jim@dlsu.edu.ph', 'ced_yu@dlsu.edu.ph', 'denise_chelsea_li@dlsu.edu.ph', 'mariliz_tan@dlsu.edu.ph', 'timmy_yap@dlsu.edu.ph', 'liana_padua@dlsu.edu.ph', 'theodore_suatengco@dlsu.edu.ph', 'jacob_austin_t_chua@dlsu.edu.ph', 'letitia_pahati@dlsu.edu.ph', 'john_joaquin_tioco@dlsu.edu.ph', 'joshua_luigi_cestina@dlsu.edu.ph', 'vladimir_tang@dlsu.edu.ph', 'ma_alexandria_apostol@dlsu.edu.ph', 'david_gochuico@dlsu.edu.ph', 'carl_justin_chiam@dlsu.edu.ph', 'tricia_hui@dlsu.edu.ph', 'jasmine_reese_yu@dlsu.edu.ph', 'lourdes_vasquez@dlsu.edu.ph', 'venice_cua@dlsu.edu.ph', 'adrian_tanchua@dlsu.edu.ph', 'sabrina_macaraya@dlsu.edu.ph', 'ethen_gobaco@dlsu.edu.ph', 'shereen_danielle_haduca@dlsu.edu.ph', 'hans_meneses@dlsu.edu.ph', 'jennalyn_dee@dlsu.edu.ph', 'lalaine_co@dlsu.edu.ph', 'lance_ulryck_corpuz@dlsu.edu.ph', 'tim_olvina@dlsu.edu.ph', 'louisse_gonzales@dlsu.edu.ph', 'eldridge_ty@dlsu.edu.ph', 'anika_caranto@dlsu.edu.ph', 'reanne_abigan@dlsu.edu.ph', 'anton_borromeo@dlsu.edu.ph', 'janray_dulatre@dlsu.edu.ph', 'ayana_paa@dlsu.edu.ph', 'razel_wang@dlsu.edu.ph', 'razel_michelle_wang@dlsu.edu.ph', 'xavier_quinones@dlsu.edu.ph', 'samantha_czkyhna_macatangay@dlsu.edu.ph', 'mikaela_lao@dlsu.edu.ph', 'keziah_sy@dlsu.edu.ph', 'jermaine_ong@dlsu.edu.ph', 'kayi_go@dlsu.edu.ph', 'marc_roosty_co@dlsu.edu.ph', 'hervyn_y_co@dlsu.edu.ph', 'ezekiel_libao@dlsu.edu.ph', 'journey_dy@dlsu.edu.ph', 'klint_ching@dlsu.edu.ph', 'irish_ty@dlsu.edu.ph', 'aaliyah_gan@dlsu.edu.ph', 'edrich_samuel_tan@dlsu.edu.ph', 'belle_elizabeth_tan@dlsu.edu.ph', 'christine_palomado@dlsu.edu.ph', 'christine_wingkee@dlsu.edu.ph', 'angeline_pua@dlsu.edu.ph', 'yao_rong_wu@dlsu.edu.ph', 'hebron_tan@dlsu.edu.ph', 'lance_angelo_ong@dlsu.edu.ph', 'clarence_so@dlsu.edu.ph', 'nathan_angping@dlsu.edu.ph', 'dave_reyes@dlsu.edu.ph', 'karl_nathan_lim@dlsu.edu.ph', 'adrian_louis_chua@dlsu.edu.ph', 'alyssa_nolasco@dlsu.edu.ph', 'maxine_ang@dlsu.edu.ph', 'julia_wenceslao@dlsu.edu.ph', 'ma_cielo_nicdao@dlsu.edu.ph', 'jarrell_ang@dlsu.edu.ph', 'francia_palatino@dlsu.edu.ph', 'dreizen_malyx_ty@dlsu.edu.ph', 'thania_calderon@dlsu.edu.ph', 'clair_lota@dlsu.edu.ph', 'wes_sy@dlsu.edu.ph', 'frodel_pascua@dlsu.edu.ph', 'janella_padilla@dlsu.edu.ph', 'willy_liu@dlsu.edu.ph', 'jamie_ross_padilla@dlsu.edu.ph', 'andrew_kho@dlsu.edu.ph', 'patricia_ignacio@dlsu.edu.ph', 'kim_russel_llanto@dlsu.edu.ph', 'shao_wang@dlsu.edu.ph', 'kayzelle_reyes@dlsu.edu.ph', 'eavie_ong@dlsu.edu.ph', 'dondon_jolito_sy@dlsu.edu.ph', 'andre_elijah_techico@dlsu.edu.ph', 'jason_pamati-an@dlsu.edu.ph', 'jeremy_james_tan@dlsu.edu.ph', 'alwyn_stefan_chang@dlsu.edu.ph', 'sidney_co@dlsu.edu.ph', 'ericka_yao@dlsu.edu.ph', 'bianca_louise_malizon@dlsu.edu.ph', 'ralf_see@dlsu.edu.ph', 'rexanne_tan@dlsu.edu.ph', 'mike_bernal@dlsu.edu.ph', 'shey_tan@dlsu.edu.ph', 'nica_sia@dlsu.edu.ph', 'milford_emerson_yao@dlsu.edu.ph', 'julianne_kirsten_tan@dlsu.edu.ph', 'kobe_buenconsejo@dlsu.edu.ph', 'grizelle_nohay@dlsu.edu.ph', 'justin_foxas@dlsu.edu.ph', 'orrin_landon_uy@dlsu.edu.ph', 'josef_antonio@dlsu.edu.ph', 'erika_see@dlsu.edu.ph', 'josfer_chuason@dlsu.edu.ph', 'maureen_amariah_b_canlas@dlsu.edu.ph', 'zelby_baluan@dlsu.edu.ph', 'byron_hung@dlsu.edu.ph', 'francesca_danica_reynoso@dlsu.edu.ph', 'erica_joy_ong@dlsu.edu.ph', 'kate_ko@dlsu.edu.ph', 'ma_tricia_ocho@dlsu.edu.ph', 'rob_simon_casao@dlsu.edu.ph');

-- | 1232 | NULL      | S1187                               | S1187                   | NULL            | 2025-06-04 19:39:17 | 2025-06-04 19:39:17 |
-- | 1628 | NULL      | 1187                                | 1187                    | NULL            | 2025-06-05 03:01:58 | 2025-06-05 03:01:58 |

-- raw events count (valid/not valid)
select count(*) as raw_event_count
from events e;
describe registrations;

-- valid events count
select count(*) as num_events_valid
from events e
join event_pubs ep on e.id = ep.event_id;

select * from events where code = 'S1137';

-- nice view for seeing all events and its necessary details
select 
    e.id as event_id, e.code, e.title as event_name, e.max_slots, e.registered_slots, e.slug,
    o.name as org_name, s.title as subtheme_title, s.id as subtheme_id
from events e
join subthemes s on s.id = e.subtheme_id
join orgs o on e.org_id = o.id;

select * from highlights;

-- Coral Lagoon       |
-- Hollowtree Hideway |
-- Northern Star Stop |
-- Pirate's Cove      |
-- Fairy Nook         |

select *, event_pubs.event_id from events
join subthemes on events.subtheme_id = subthemes.id
join event_pubs on events.id = event_pubs.event_id
where subthemes.title = 'Northern Star Stop'; 

select * from users;
select * from events
join subthemes on events.subtheme_id = subthemes.id
where subthemes.title = 'Fairy Nook'; 

select * from events;
describe events;

select * from registrations;

-- select * 
-- from users
-- join registrations on users.id = registrations.user_id
-- where 

select * from orgs;
select * from subthemes;
select * from highlights;
select * from bookmarks;

select * from bookmarks where user_id = 17;
-- delete from bookmarks where user_id = 17;

select * from event_pubs;

select * from users where google_id = '111243794591993826636';

-- 4BG3zewIeFJ2xvk22b2yXa
-- 7K0NFLdBOBR8zfzMgtmxyC

SELECT * FROM events WHERE contentful_id = "7yL8t9BQB39cVvk2ipbI0e1";
-- Pirate's Cove      _  14HbDbAmkbEDkcZY8BlWlr 
-- Northern Star Stop _  3pCrlfHwuorwSLqG2xvlp2 
-- Fairy Nook         _  4MoJeQ0j0mKYXVm9t4fOH4 
-- Hollowtree Hideway _  15QlwnWhbujXqEYgJjtJXE 
-- Coral Lagoon       _  7GK22pAquYAd8EkzNK41ir 

select 
    count(*) as num_registrations
from registrations
join users on registrations.user_id = users.id
join events on registrations.event_id = events.id
where registrations.event_id = 6;


select * from users where id = 3963;
select id, google_id, email, name, created_at, updated_at from users where email like 'casey_oreta%';

select * from users;
describe users;
-- check id of event here
select id as event_id, title from events where code like '%S1001%';
select * from users where email = 'NULL';

SELECT 
    users.email,
    CASE WHEN users.email IS NOT NULL THEN 'Found' ELSE 'Not Found' END AS status
FROM 
    (SELECT 'shina_may_lim@dlsu.edu.ph' AS email
     UNION ALL SELECT 'gerald_christopher_aguilar@dlsu.edu.ph'
     UNION ALL SELECT 'jeremy_palacios@dlsu.edu.ph'
     UNION ALL SELECT 'bea_arcega@dlsu.edu.ph'
     UNION ALL SELECT 'jalene_siazon@dlsu.edu.ph'
     UNION ALL SELECT 'reese_devera@dlsu.edu.ph'
     UNION ALL SELECT 'romel_caragay@dlsu.edu.ph'
     UNION ALL SELECT 'alessandra_aguilar@dlsu.edu.ph'
     UNION ALL SELECT 'mackenzie_garcia@dlsu.edu.ph'
     UNION ALL SELECT 'japheth_fernandez@dlsu.edu.ph'
     UNION ALL SELECT 'lorenz_alog@dlsu.edu.ph'
     UNION ALL SELECT 'marianne_gopez@dlsu.edu.ph'
     UNION ALL SELECT 'rono_salapunen@dlsu.edu.ph'
     UNION ALL SELECT 'earl_benedict_lisaba@dlsu.edu.ph'
     UNION ALL SELECT 'sean_nathan_sy@dlsu.edu.ph'
     UNION ALL SELECT 'patricia_baterina@dlsu.edu.ph'
     UNION ALL SELECT 'casey_oreta@dlsu.edu.ph'
     UNION ALL SELECT 'jose_alexis_baldonado@dlsu.edu.ph'
     UNION ALL SELECT 'julia_pobre@dlsu.edu.ph'
     UNION ALL SELECT 'kaitlyn_gamis@dlsu.edu.ph') AS email_list
LEFT JOIN 
    users ON users.email = email_list.email;

select count(*) as num_registrations from registrations where event_id = 8; 
select * from events where id = 14;


select * from events where id = 20;

-- TODO: [2025-06-05 02:46]
-- - block blast - no access to gforms_url
-- - sail across the world - 404 bc gforms_url is n/a
-- - expanding horizon - wrong gfroms (CRITICAL!)
-- we learned that layer 8 is the most problematic layer in the osi layers


select * from events;

-- count all users
select count(*) as num_total_users
from users;

-- count all registrations
select count(*) as num_registrations
from registrations;

select * from users;
select * from registrations;

-- -- grep event by title (also checks if it is in registrations table, and actual_registered_count)
-- select 
--     events.id as event_id,
--     events.title as event_title,
--     subthemes.title as subtheme_title,
--     events.code,
--     events.max_slots,
--     events.registered_slots,
--     count(registrations.event_id) as actual_registered_count,
--     case 
--     when exists (
--         select 1
--         from registrations
--         where registrations.event_id = events.id
--     ) then 'true' else 'false'
--     end as is_in_registrations_table
-- from events 
-- join subthemes on events.subtheme_id = subthemes.id
-- join registrations on registrations.event_id = events.id
-- where events.title like '%karaoke%'
-- group by event_id;

select * from events;

select * from users where users.email like '%ching%';
select * from registrations;
insert into registrations (registrations.user_id, registrations.event_id) values (1215, 8)

delete from users where users.id = 411;

-- check subtheme of an event
select events.id, events.title, subthemes.title 
from events
join subthemes on events.subtheme_id = subthemes.id
where events.title like '%where%';

-- count num_registrations per event (selects actual registrations recorded on registrations table)
select 
    events.id as event_id,
    events.title,
    events.max_slots,
    events.registered_slots,
    count(registrations.event_id) as actual_registered_count
from events
join registrations on registrations.event_id = events.id
group by event_id;

-- SELECT * FROM subthemes WHERE title = 'Pirate\'s Cove';

