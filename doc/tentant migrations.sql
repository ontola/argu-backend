
//Question
insert into nederland.questions (id, title, content, forum_id, creator_id, is_trashed, motions_count, votes_pro_count, votes_con_count, created_at, updated_at, cover_photo, cover_photo_attribution, expires_at)
select id, title, content, forum_id, creator_id, is_trashed, motions_count, votes_pro_count, votes_con_count, created_at, updated_at, cover_photo, cover_photo_attribution, expires_at
from public.questions
where forum_id = 3;

//Motion
insert into nederland.motions (id, title, content, created_at, updated_at, pro_count, con_count, tag_id, is_trashed, votes_pro_count, votes_con_count, votes_neutral_count, argument_pro_count, argument_con_count, opinion_pro_count, opinion_con_count, votes_abstain_count, forum_id, creator_id, cover_photo, cover_photo_attribution)
select id, title, content, created_at, updated_at, pro_count, con_count, tag_id, is_trashed, votes_pro_count, votes_con_count, votes_neutral_count, argument_pro_count, argument_con_count, opinion_pro_count, opinion_con_count, votes_abstain_count, forum_id, creator_id, cover_photo, cover_photo_attribution
from public.motions
where forum_id = 3;

insert into nederland.arguments (id, content, motion_id, pro, created_at, updated_at, title, is_trashed, votes_pro_count, comments_count, votes_abstain_count, creator_id, votes_con_count, forum_id)
select id, content, motion_id, pro, created_at, updated_at, title, is_trashed, votes_pro_count, comments_count, votes_abstain_count, creator_id, votes_con_count, forum_id
from public.arguments
where forum_id = 3;

insert into nederland.votes (id, voteable_id, voteable_type, voter_id, voter_type, "for", created_at, updated_at, forum_id)
select id, voteable_id, voteable_type, voter_id, voter_type, "for", created_at, updated_at, forum_id
from public.votes
where forum_id = 3;

insert into nederland.memberships (id, profile_id,  forum_id,  role)
select id, profile_id,  forum_id,  role
from public.memberships
where forum_id = 3;

insert into nederland.groups (id, forum_id, name, created_at, updated_at, name_singular, max_responses_per_member, icon)
select id, forum_id, name, created_at, updated_at, name_singular, max_responses_per_member, icon
from public.groups
where forum_id = 3;

insert into nederland.access_tokens (id, item_id, item_type, access_token, profile_id, usages, created_at, updated_at, sign_ups)
select id, item_id, item_type, access_token, profile_id, usages, created_at, updated_at, sign_ups
from public.access_tokens
where item_type = 'Forum' AND item_id = 3;

