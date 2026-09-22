TableName	ColumnName	OrdinalPosition	DataTypeDefinition	IsNullable	DefaultValue	IsPrimaryKey	IsForeignKey	ReferencedTable	ReferencedColumn
awards_tbl	award_id	1	int	NO	NULL	YES	NO		
awards_tbl	award_year	2	nvarchar(50)	NO	NULL	NO	NO		
awards_tbl	title	3	nvarchar(150)	NO	NULL	NO	NO		
awards_tbl	subtitle	4	nvarchar(150)	NO	NULL	NO	NO		
awards_tbl	organization_name	5	nvarchar(200)	NO	NULL	NO	NO		
awards_tbl	is_active	6	bit	YES	((1))	NO	NO		
awards_tbl	user_id	7	int	NO	NULL	NO	YES	users_tbl	user_id
educations_tbl	edu_id	1	int	NO	NULL	YES	NO		
educations_tbl	title	2	nvarchar(150)	NO	NULL	NO	NO		
educations_tbl	subtitle	3	nvarchar(150)	NO	NULL	NO	NO		
educations_tbl	institution_name	4	nvarchar(200)	NO	NULL	NO	NO		
educations_tbl	is_active	5	bit	YES	((1))	NO	NO		
educations_tbl	user_id	6	int	NO	NULL	NO	YES	users_tbl	user_id
educations_tbl	start_year	7	int	NO	NULL	NO	NO		
educations_tbl	end_year	8	int	YES	NULL	NO	NO		
educations_tbl	is_current	9	bit	NO	NULL	NO	NO		
experiences_tbl	exp_id	1	int	NO	NULL	YES	NO		
experiences_tbl	role_title	2	nvarchar(150)	NO	NULL	NO	NO		
experiences_tbl	company_name	3	nvarchar(150)	NO	NULL	NO	NO		
experiences_tbl	description_text	4	nvarchar(MAX)	YES	NULL	NO	NO		
experiences_tbl	tags	5	nvarchar(255)	YES	NULL	NO	NO		
experiences_tbl	is_active	6	bit	YES	((1))	NO	NO		
experiences_tbl	user_id	7	int	NO	NULL	NO	YES	users_tbl	user_id
experiences_tbl	start_year	8	int	NO	NULL	NO	NO		
experiences_tbl	end_year	9	int	YES	NULL	NO	NO		
experiences_tbl	is_current	10	bit	NO	NULL	NO	NO		
hobbies_tbl	hobby_id	1	int	NO	NULL	YES	NO		
hobbies_tbl	hobby_name	2	nvarchar(150)	NO	NULL	NO	NO		
hobbies_tbl	is_active	3	bit	YES	((1))	NO	NO		
hobbies_tbl	user_id	4	int	NO	NULL	NO	YES	users_tbl	user_id
hobbies_tbl	hobby_description	5	nvarchar(500)	YES	NULL	NO	NO		
password_resets_tbl	reset_id	1	int	NO	NULL	YES	NO		
password_resets_tbl	user_id	2	int	YES	NULL	NO	YES	users_tbl	user_id
password_resets_tbl	email	3	nvarchar(150)	NO	NULL	NO	NO		
password_resets_tbl	reason	4	nvarchar(500)	YES	NULL	NO	NO		
password_resets_tbl	status	5	nvarchar(50)	YES	('pending')	NO	NO		
password_resets_tbl	created_at	6	datetime	YES	(getdate())	NO	NO		
password_resets_tbl	reset_token	7	nvarchar(256)	YES	NULL	NO	NO		
password_resets_tbl	expires_at	8	datetime	YES	NULL	NO	NO		
profile_tbl	profile_id	1	int	NO	NULL	YES	NO		
profile_tbl	hero_subline	2	nvarchar(150)	YES	NULL	NO	NO		
profile_tbl	hero_names	3	nvarchar(500)	YES	NULL	NO	NO		
profile_tbl	role_summary	4	nvarchar(MAX)	YES	NULL	NO	NO		
profile_tbl	role_title	5	nvarchar(150)	YES	NULL	NO	NO		
profile_tbl	focus_area	6	nvarchar(150)	YES	NULL	NO	NO		
profile_tbl	based_in	7	nvarchar(150)	YES	NULL	NO	NO		
profile_tbl	avatar_path	8	nvarchar(255)	YES	NULL	NO	NO		
profile_tbl	location_address	9	nvarchar(255)	YES	NULL	NO	NO		
profile_tbl	experience_years	10	int	YES	NULL	NO	NO		
profile_tbl	email	11	nvarchar(150)	YES	NULL	NO	NO		
profile_tbl	github_url	12	nvarchar(255)	YES	NULL	NO	NO		
profile_tbl	linkedin_url	13	nvarchar(255)	YES	NULL	NO	NO		
profile_tbl	updated_at	14	datetime	YES	(getdate())	NO	NO		
profile_tbl	user_id	15	int	NO	NULL	NO	YES	users_tbl	user_id
profile_tbl	birth_date	16	date	YES	NULL	NO	NO		
projects_tbl	project_id	1	int	NO	NULL	YES	NO		
projects_tbl	title	2	nvarchar(150)	NO	NULL	NO	NO		
projects_tbl	image_path	3	nvarchar(255)	NO	NULL	NO	NO		
projects_tbl	project_url	4	nvarchar(255)	YES	NULL	NO	NO		
projects_tbl	tags	5	nvarchar(255)	YES	NULL	NO	NO		
projects_tbl	is_active	6	bit	YES	((1))	NO	NO		
projects_tbl	user_id	7	int	NO	NULL	NO	YES	users_tbl	user_id
skills_tbl	skill_id	1	int	NO	NULL	YES	NO		
skills_tbl	skill_name	2	nvarchar(150)	NO	NULL	NO	NO		
skills_tbl	proficiency_val	3	int	NO	NULL	NO	NO		
skills_tbl	is_active	4	bit	YES	((1))	NO	NO		
skills_tbl	user_id	5	int	NO	NULL	NO	YES	users_tbl	user_id
tech_stacks_tbl	tech_id	1	int	NO	NULL	YES	NO		
tech_stacks_tbl	group_name	2	nvarchar(100)	NO	NULL	NO	NO		
tech_stacks_tbl	label	3	nvarchar(100)	NO	NULL	NO	NO		
tech_stacks_tbl	icon_path	4	nvarchar(255)	NO	NULL	NO	NO		
tech_stacks_tbl	is_active	5	bit	YES	((1))	NO	NO		
tech_stacks_tbl	user_id	6	int	NO	NULL	NO	YES	users_tbl	user_id
user_logins_tbl	login_id	1	int	NO	NULL	YES	NO		
user_logins_tbl	user_id	2	int	NO	NULL	NO	YES	users_tbl	user_id
user_logins_tbl	login_time	3	datetime	NO	(getdate())	NO	NO		
user_logins_tbl	ip_address	4	nvarchar(100)	YES	NULL	NO	NO		
user_logins_tbl	user_agent	5	nvarchar(500)	YES	NULL	NO	NO		
users_tbl	user_id	1	int	NO	NULL	YES	NO		
users_tbl	first_name	2	nvarchar(150)	NO	NULL	NO	NO		
users_tbl	last_name	3	nvarchar(150)	NO	NULL	NO	NO		
users_tbl	email	4	nvarchar(150)	NO	NULL	NO	NO		
users_tbl	password_hash	5	nvarchar(256)	NO	NULL	NO	NO		
users_tbl	user_role	6	nvarchar(50)	YES	('User')	NO	NO		
users_tbl	is_active	7	bit	YES	((1))	NO	NO		
users_tbl	created_at	8	datetime	YES	(getdate())	NO	NO		
users_tbl	last_login_at	9	datetime	YES	NULL	NO	NO		
users_tbl	login_count	10	int	NO	((0))	NO	NO		
