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


select id, name from users where email = '@dlsu.edu.ph';

-- - shana_haw@dlsu.edu.ph
-- - jasmine_guerrero@dlsu.edu.ph
-- - princess_caresse_maravillas@dlsu.edu.ph
-- - liriane_magsino@dlsu.edu.ph
-- - fredelyn_ang@dlsu.edu.ph

select * from events;

insert into registrations (user_id, event_id) values (561, 8);

select * from events;

select * from registrations;

-- filter events that has 1 available slots left
select events.id, events.title as event_title, events.code, events.max_slots, events.registered_slots
from events
where (events.max_slots - events.registered_slots) = 1;

-- grep event by title (also checks if it is in registrations table, and actual_registered_count)
select 
    events.id as event_id,
    events.title as event_title,
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
    subthemes.title as subtheme_title,
    events.gforms_url
from events 
join subthemes on events.subtheme_id = subthemes.id
where events.title like '%expanding%';

-- NOTE: events that are "not automatic" incrementing (maybe)
-- event_id = 70 | Dance into the Night Away | S1201
-- event_id = 78 | Skybound Strokes: Painting a World Without Limits | S1004

select id as event_id, title as event_title, code, max_slots, registered_slots from events where code like '%S1053%';

-- simple check for slot updater (to check event id of what to update)
select id as event_id, title as event_title, code, max_slots, registered_slots from events where id = 6 or id = 59;
-- slot updater
update events set registered_slots = 12 where id = 70;

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
    (SELECT 'email' AS email
     UNION ALL SELECT 'email'
     UNION ALL SELECT '@dlsu.edu.ph') AS email_list
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

