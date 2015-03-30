

-- --------------------------------------------------------

--
-- Table structure for table icinga_acknowledgements
--
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_acknowledgements') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE icinga_acknowledgements (
  acknowledgement_id bigint NOT NULL IDENTITY,
  instance_id bigint  default 0,
  entry_time datetime default null,
  entry_time_usec  int default 0,
  acknowledgement_type smallint default 0,
  object_id bigint  default 0,
  state smallint default 0,
  author_name varchar(64)   default '',
  comment_data TEXT   default '',
  is_sticky smallint default 0,
  persistent_comment smallint default 0,
  notify_contacts smallint default 0,
  end_time datetime default null,
  PRIMARY KEY  (acknowledgement_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_commands
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_commands') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_commands (
  command_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  object_id bigint  default 0,
  command_line TEXT   default '',
  PRIMARY KEY  (command_id),
  CONSTRAINT commands_instance_id UNIQUE (instance_id,object_id,config_type)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_commenthistory
--
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_commenthistory') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_commenthistory (
  commenthistory_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  entry_time datetime default null,
  entry_time_usec  int default 0,
  comment_type smallint default 0,
  entry_type smallint default 0,
  object_id bigint  default 0,
  comment_time datetime  default null,
  internal_comment_id bigint  default 0,
  author_name varchar(64)   default '',
  comment_data TEXT   default '',
  is_persistent smallint default 0,
  comment_source smallint default 0,
  expires smallint default 0,
  expiration_time datetime  default null,
  deletion_time datetime  default null,
  deletion_time_usec  int default 0,
  PRIMARY KEY  (commenthistory_id),
  CONSTRAINT commenthistory_instance_id UNIQUE (instance_id,object_id,comment_time,internal_comment_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_comments
--
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_comments') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_comments (
  comment_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  entry_time datetime  default null,
  entry_time_usec  int default 0,
  comment_type smallint default 0,
  entry_type smallint default 0,
  object_id bigint  default 0,
  comment_time datetime default null,
  internal_comment_id bigint  default 0,
  author_name varchar(64)   default '',
  comment_data TEXT   default '',
  is_persistent smallint default 0,
  comment_source smallint default 0,
  expires smallint default 0,
  expiration_time datetime default null,
  PRIMARY KEY  (comment_id),
  CONSTRAINT comments_instance_id UNIQUE (instance_id,object_id,comment_time,internal_comment_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_configfiles
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_configfiles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE icinga_configfiles (
  configfile_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  configfile_type smallint default 0,
  configfile_path varchar(255)   default '',
  PRIMARY KEY  (configfile_id),
  CONSTRAINT configfiles_instance_id UNIQUE (instance_id,configfile_type,configfile_path)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_configfilevariables
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_configfilevariables') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_configfilevariables (
  configfilevariable_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  configfile_id bigint  default 0,
  varname varchar(64)   default '',
  varvalue TEXT   default '',
  PRIMARY KEY  (configfilevariable_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_conninfo
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_conninfo') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_conninfo (
  conninfo_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  agent_name varchar(32)   default '',
  agent_version varchar(32)   default '',
  disposition varchar(32)   default '',
  connect_source varchar(32)   default '',
  connect_type varchar(32)   default '',
  connect_time datetime default null,
  disconnect_time datetime default null,
  last_checkin_time datetime default null,
  data_start_time datetime default null,
  data_end_time datetime default null,
  bytes_processed bigint   default '0',
  lines_processed bigint   default '0',
  entries_processed bigint   default '0',
  PRIMARY KEY  (conninfo_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contactgroups
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contactgroups') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contactgroups (
  contactgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  contactgroup_object_id bigint  default 0,
  alias TEXT   default '',
  PRIMARY KEY  (contactgroup_id),
  CONSTRAINT contactgroups_instance_id UNIQUE (instance_id,config_type,contactgroup_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contactgroup_members
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contactgroup_members') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contactgroup_members (
  contactgroup_member_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  contactgroup_id bigint  default 0,
  contact_object_id bigint  default 0,
  PRIMARY KEY  (contactgroup_member_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contactnotificationmethods
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contactnotificationmethods') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contactnotificationmethods (
  contactnotificationmethod_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  contactnotification_id bigint  default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  command_object_id bigint  default 0,
  command_args TEXT   default '',
  PRIMARY KEY  (contactnotificationmethod_id),
  CONSTRAINT contactnotificationmethods_instance_id UNIQUE (instance_id,contactnotification_id,start_time,start_time_usec)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contactnotifications
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contactnotifications') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contactnotifications (
  contactnotification_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  notification_id bigint  default 0,
  contact_object_id bigint  default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  PRIMARY KEY  (contactnotification_id),
  CONSTRAINT contactnotifications_instance_id UNIQUE (instance_id,contact_object_id,start_time,start_time_usec)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contacts
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contacts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contacts (
  contact_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  contact_object_id bigint  default 0,
  alias TEXT   default '',
  email_address varchar(255)   default '',
  pager_address varchar(64)   default '',
  host_timeperiod_object_id bigint  default 0,
  service_timeperiod_object_id bigint  default 0,
  host_notifications_enabled smallint default 0,
  service_notifications_enabled smallint default 0,
  can_submit_commands smallint default 0,
  notify_service_recovery smallint default 0,
  notify_service_warning smallint default 0,
  notify_service_unknown smallint default 0,
  notify_service_critical smallint default 0,
  notify_service_flapping smallint default 0,
  notify_service_downtime smallint default 0,
  notify_host_recovery smallint default 0,
  notify_host_down smallint default 0,
  notify_host_unreachable smallint default 0,
  notify_host_flapping smallint default 0,
  notify_host_downtime smallint default 0,
  PRIMARY KEY  (contact_id),
  CONSTRAINT contacts_instance_id UNIQUE (instance_id,config_type,contact_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contactstatus
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contactstatus') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contactstatus (
  contactstatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  contact_object_id bigint  default 0,
  status_update_time datetime default null,
  host_notifications_enabled smallint default 0,
  service_notifications_enabled smallint default 0,
  last_host_notification datetime default null,
  last_service_notification datetime default null,
  modified_attributes  int default 0,
  modified_host_attributes  int default 0,
  modified_service_attributes  int default 0,
  PRIMARY KEY  (contactstatus_id),
  CONSTRAINT contact_object_id UNIQUE (contact_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contact_addresses
--

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contact_addresses') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contact_addresses (
  contact_address_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  contact_id bigint  default 0,
  address_number smallint default 0,
  address varchar(255)   default '',
  PRIMARY KEY  (contact_address_id),
  CONSTRAINT contact_addresses_contact_id UNIQUE (contact_id,address_number)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_contact_notificationcommands
--
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_contact_notificationcommands') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_contact_notificationcommands (
  contact_notificationcommand_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  contact_id bigint  default 0,
  notification_type smallint default 0,
  command_object_id bigint  default 0,
  command_args varchar(255)   default '',
  PRIMARY KEY  (contact_notificationcommand_id),
  CONSTRAINT contact_notificationcommands_contact_id UNIQUE (contact_id,notification_type,command_object_id,command_args)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_customvariables
--
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'icinga_customvariables') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE  icinga_customvariables (
  customvariable_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  object_id bigint  default 0,
  config_type smallint default 0,
  has_been_modified smallint default 0,
  varname varchar(255) default NULL,
  varvalue TEXT   default '',
  is_json smallint default 0,
  PRIMARY KEY  (customvariable_id),
  CONSTRAINT customvariables_object_id_2 UNIQUE (object_id,config_type,varname)
);

CREATE INDEX varname ON icinga_customvariables(varname);

-- --------------------------------------------------------

--
-- Table structure for table icinga_customvariablestatus
--

CREATE TABLE  icinga_customvariablestatus (
  customvariablestatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  object_id bigint  default 0,
  status_update_time datetime default null,
  has_been_modified smallint default 0,
  varname varchar(255) default NULL,
  varvalue TEXT   default '',
  is_json smallint default 0,
  PRIMARY KEY  (customvariablestatus_id),
  CONSTRAINT customvariablestatus_object_id_2 UNIQUE (object_id,varname)
);

CREATE INDEX varname ON icinga_customvariablestatus(varname);

-- --------------------------------------------------------

--
-- Table structure for table icinga_dbversion
--

CREATE TABLE  icinga_dbversion (
  dbversion_id bigint  NOT NULL IDENTITY,
  name varchar(10)   default '',
  version varchar(10)   default '',
  create_time datetime default null,
  modify_time datetime default null,
  PRIMARY KEY (dbversion_id),
  CONSTRAINT dbversion UNIQUE (name)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_downtimehistory
--

CREATE TABLE  icinga_downtimehistory (
  downtimehistory_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  downtime_type smallint default 0,
  object_id bigint  default 0,
  entry_time datetime default null,
  author_name varchar(64)   default '',
  comment_data TEXT   default '',
  internal_downtime_id bigint  default 0,
  triggered_by_id bigint  default 0,
  is_fixed smallint default 0,
  duration bigint default 0,
  scheduled_start_time datetime default null,
  scheduled_end_time datetime default null,
  was_started smallint default 0,
  actual_start_time datetime default null,
  actual_start_time_usec  int default 0,
  actual_end_time datetime default null,
  actual_end_time_usec  int default 0,
  was_cancelled smallint default 0,
  is_in_effect smallint default 0,
  trigger_time datetime default null,
  PRIMARY KEY  (downtimehistory_id),
  CONSTRAINT downtimehistory_instance_id UNIQUE (instance_id,object_id,entry_time,internal_downtime_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_eventhandlers
--

CREATE TABLE  icinga_eventhandlers (
  eventhandler_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  eventhandler_type smallint default 0,
  object_id bigint  default 0,
  state smallint default 0,
  state_type smallint default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  command_object_id bigint  default 0,
  command_args TEXT   default '',
  command_line TEXT   default '',
  timeout smallint default 0,
  early_timeout smallint default 0,
  execution_time float default '0',
  return_code smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  PRIMARY KEY  (eventhandler_id),
  CONSTRAINT eventhandlers_instance_id UNIQUE (instance_id,object_id,start_time,start_time_usec)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_externalcommands
--

CREATE TABLE  icinga_externalcommands (
  externalcommand_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  entry_time datetime default null,
  command_type smallint default 0,
  command_name varchar(128)   default '',
  command_args TEXT   default '',
  PRIMARY KEY  (externalcommand_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_flappinghistory
--

CREATE TABLE  icinga_flappinghistory (
  flappinghistory_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  event_time datetime default null,
  event_time_usec  int default 0,
  event_type smallint default 0,
  reason_type smallint default 0,
  flapping_type smallint default 0,
  object_id bigint  default 0,
  percent_state_change float default '0',
  low_threshold float default '0',
  high_threshold float default '0',
  comment_time datetime default null,
  internal_comment_id bigint  default 0,
  PRIMARY KEY (flappinghistory_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostchecks
--

CREATE TABLE  icinga_hostchecks (
  hostcheck_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  host_object_id bigint  default 0,
  check_type smallint default 0,
  is_raw_check smallint default 0,
  current_check_attempt smallint default 0,
  max_check_attempts smallint default 0,
  state smallint default 0,
  state_type smallint default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  command_object_id bigint  default 0,
  command_args TEXT   default '',
  command_line TEXT   default '',
  timeout smallint default 0,
  early_timeout smallint default 0,
  execution_time float default '0',
  latency float default '0',
  return_code smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  perfdata TEXT   default '',
  PRIMARY KEY  (hostcheck_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostdependencies
--

CREATE TABLE  icinga_hostdependencies (
  hostdependency_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  host_object_id bigint  default 0,
  dependent_host_object_id bigint  default 0,
  dependency_type smallint default 0,
  inherits_parent smallint default 0,
  timeperiod_object_id bigint  default 0,
  fail_on_up smallint default 0,
  fail_on_down smallint default 0,
  fail_on_unreachable smallint default 0,
  PRIMARY KEY  (hostdependency_id)
);

CREATE INDEX instance_id ON icinga_hostdependencies(instance_id,config_type,host_object_id,dependent_host_object_id,dependency_type,inherits_parent,fail_on_up,fail_on_down,fail_on_unreachable);


-- --------------------------------------------------------

--
-- Table structure for table icinga_hostescalations
--

CREATE TABLE  icinga_hostescalations (
  hostescalation_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  host_object_id bigint  default 0,
  timeperiod_object_id bigint  default 0,
  first_notification smallint default 0,
  last_notification smallint default 0,
  notification_interval float default '0',
  escalate_on_recovery smallint default 0,
  escalate_on_down smallint default 0,
  escalate_on_unreachable smallint default 0,
  PRIMARY KEY  (hostescalation_id),
  CONSTRAINT hostescalations_instance_id UNIQUE (instance_id,config_type,host_object_id,timeperiod_object_id,first_notification,last_notification)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostescalation_contactgroups
--

CREATE TABLE  icinga_hostescalation_contactgroups (
  hostescalation_contactgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  hostescalation_id bigint  default 0,
  contactgroup_object_id bigint  default 0,
  PRIMARY KEY  (hostescalation_contactgroup_id),
  CONSTRAINT hostescalation_contactgroups_instance_id UNIQUE (hostescalation_id,contactgroup_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostescalation_contacts
--

CREATE TABLE  icinga_hostescalation_contacts (
  hostescalation_contact_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  hostescalation_id bigint  default 0,
  contact_object_id bigint  default 0,
  PRIMARY KEY  (hostescalation_contact_id),
  CONSTRAINT hostescalation_contacts_instance_id UNIQUE (instance_id,hostescalation_id,contact_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostgroups
--

CREATE TABLE  icinga_hostgroups (
  hostgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  hostgroup_object_id bigint  default 0,
  alias TEXT   default '',
  notes TEXT   default NULL,
  notes_url TEXT   default NULL,
  action_url TEXT   default NULL,
  PRIMARY KEY  (hostgroup_id),
  CONSTRAINT hostgroups_instance_id UNIQUE (instance_id,hostgroup_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hostgroup_members
--

CREATE TABLE  icinga_hostgroup_members (
  hostgroup_member_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  hostgroup_id bigint  default 0,
  host_object_id bigint  default 0,
  PRIMARY KEY  (hostgroup_member_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_hosts
--

CREATE TABLE  icinga_hosts (
  host_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  host_object_id bigint  default 0,
  alias TEXT   default '',
  display_name varchar(255)   default '',
  address varchar(128)   default '',
  address6 varchar(128)   default '',
  check_command_object_id bigint  default 0,
  check_command_args TEXT   default '',
  eventhandler_command_object_id bigint  default 0,
  eventhandler_command_args TEXT   default '',
  notification_timeperiod_object_id bigint  default 0,
  check_timeperiod_object_id bigint  default 0,
  failure_prediction_options varchar(128)   default '',
  check_interval float default '0',
  retry_interval float default '0',
  max_check_attempts smallint default 0,
  first_notification_delay float default '0',
  notification_interval float default '0',
  notify_on_down smallint default 0,
  notify_on_unreachable smallint default 0,
  notify_on_recovery smallint default 0,
  notify_on_flapping smallint default 0,
  notify_on_downtime smallint default 0,
  stalk_on_up smallint default 0,
  stalk_on_down smallint default 0,
  stalk_on_unreachable smallint default 0,
  flap_detection_enabled smallint default 0,
  flap_detection_on_up smallint default 0,
  flap_detection_on_down smallint default 0,
  flap_detection_on_unreachable smallint default 0,
  low_flap_threshold float default '0',
  high_flap_threshold float default '0',
  process_performance_data smallint default 0,
  freshness_checks_enabled smallint default 0,
  freshness_threshold smallint default 0,
  passive_checks_enabled smallint default 0,
  event_handler_enabled smallint default 0,
  active_checks_enabled smallint default 0,
  retain_status_information smallint default 0,
  retain_nonstatus_information smallint default 0,
  notifications_enabled smallint default 0,
  obsess_over_host smallint default 0,
  failure_prediction_enabled smallint default 0,
  notes TEXT   default '',
  notes_url TEXT   default '',
  action_url TEXT   default '',
  icon_image TEXT   default '',
  icon_image_alt TEXT   default '',
  vrml_image TEXT   default '',
  statusmap_image TEXT   default '',
  have_2d_coords smallint default 0,
  x_2d smallint default 0,
  y_2d smallint default 0,
  have_3d_coords smallint default 0,
  x_3d float default '0',
  y_3d float default '0',
  z_3d float default '0',
  PRIMARY KEY  (host_id),
  CONSTRAINT hosts_instance_id UNIQUE (instance_id,config_type,host_object_id)
);

CREATE INDEX host_object_id ON icinga_hosts(host_object_id);


-- --------------------------------------------------------

--
-- Table structure for table icinga_hoststatus
--

CREATE TABLE  icinga_hoststatus (
  hoststatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  host_object_id bigint  default 0,
  status_update_time datetime default null,
  output TEXT   default '',
  long_output TEXT  default '',
  perfdata TEXT   default '',
  check_source TEXT   default '',
  current_state smallint default 0,
  has_been_checked smallint default 0,
  should_be_scheduled smallint default 0,
  current_check_attempt smallint default 0,
  max_check_attempts smallint default 0,
  last_check datetime default null,
  next_check datetime default null,
  check_type smallint default 0,
  last_state_change datetime default null,
  last_hard_state_change datetime default null,
  last_hard_state smallint default 0,
  last_time_up datetime default null,
  last_time_down datetime default null,
  last_time_unreachable datetime default null,
  state_type smallint default 0,
  last_notification datetime default null,
  next_notification datetime default null,
  no_more_notifications smallint default 0,
  notifications_enabled smallint default 0,
  problem_has_been_acknowledged smallint default 0,
  acknowledgement_type smallint default 0,
  current_notification_number smallint default 0,
  passive_checks_enabled smallint default 0,
  active_checks_enabled smallint default 0,
  event_handler_enabled smallint default 0,
  flap_detection_enabled smallint default 0,
  is_flapping smallint default 0,
  percent_state_change float default '0',
  latency float default '0',
  execution_time float default '0',
  scheduled_downtime_depth smallint default 0,
  failure_prediction_enabled smallint default 0,
  process_performance_data smallint default 0,
  obsess_over_host smallint default 0,
  modified_host_attributes  int default 0,
  event_handler TEXT   default '',
  check_command TEXT   default '',
  normal_check_interval float default '0',
  retry_check_interval float default '0',
  check_timeperiod_object_id bigint  default 0,
  is_reachable smallint default 0,
  PRIMARY KEY (hoststatus_id),
  CONSTRAINT object_id UNIQUE (host_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_host_contactgroups
--

CREATE TABLE  icinga_host_contactgroups (
  host_contactgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  host_id bigint  default 0,
  contactgroup_object_id bigint  default 0,
  PRIMARY KEY  (host_contactgroup_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_host_contacts
--

CREATE TABLE  icinga_host_contacts (
  host_contact_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  host_id bigint  default 0,
  contact_object_id bigint  default 0,
  PRIMARY KEY  (host_contact_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_host_parenthosts
--

CREATE TABLE  icinga_host_parenthosts (
  host_parenthost_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  host_id bigint  default 0,
  parent_host_object_id bigint  default 0,
  PRIMARY KEY  (host_parenthost_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_instances
--

CREATE TABLE  icinga_instances (
  instance_id bigint  NOT NULL IDENTITY,
  instance_name varchar(64)   default '',
  instance_description varchar(128)   default '',
  PRIMARY KEY  (instance_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_logentries
--

CREATE TABLE  icinga_logentries (
  logentry_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  logentry_time datetime default null,
  entry_time datetime default null,
  entry_time_usec  int default 0,
  logentry_type  int default 0,
  logentry_data TEXT   default '',
  realtime_data smallint default 0,
  inferred_data_extracted smallint default 0,
  object_id bigint  default NULL,
  PRIMARY KEY  (logentry_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_notifications
--

CREATE TABLE  icinga_notifications (
  notification_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  notification_type smallint default 0,
  notification_reason smallint default 0,
  object_id bigint  default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  state smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  escalated smallint default 0,
  contacts_notified smallint default 0,
  PRIMARY KEY  (notification_id),
  CONSTRAINT notifications_instance_id UNIQUE (instance_id,object_id,start_time,start_time_usec)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_objects
--

CREATE TABLE  icinga_objects (
  object_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  objecttype_id bigint  default 0,
  name1 varchar(128) default '',
  name2 varchar(128) default NULL,
  is_active smallint default 0,
  PRIMARY KEY  (object_id)
);

CREATE INDEX objecttype_id ON icinga_objects(objecttype_id,name1,name2);

-- --------------------------------------------------------

--
-- Table structure for table icinga_processevents
--

CREATE TABLE  icinga_processevents (
  processevent_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  event_type smallint default 0,
  event_time datetime default null,
  event_time_usec  int default 0,
  process_id bigint  default 0,
  program_name varchar(16)   default '',
  program_version varchar(20)   default '',
  program_date varchar(10)   default '',
  PRIMARY KEY  (processevent_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_programstatus
--

CREATE TABLE  icinga_programstatus (
  programstatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  program_version varchar(64) default NULL,
  status_update_time datetime default null,
  program_start_time datetime default null,
  program_end_time datetime default null,
  endpoint_name varchar(255) default NULL,
  is_currently_running smallint default 0,
  process_id bigint  default 0,
  daemon_mode smallint default 0,
  last_command_check datetime default null,
  last_log_rotation datetime default null,
  notifications_enabled smallint default 0,
  disable_notif_expire_time datetime default null,
  active_service_checks_enabled smallint default 0,
  passive_service_checks_enabled smallint default 0,
  active_host_checks_enabled smallint default 0,
  passive_host_checks_enabled smallint default 0,
  event_handlers_enabled smallint default 0,
  flap_detection_enabled smallint default 0,
  failure_prediction_enabled smallint default 0,
  process_performance_data smallint default 0,
  obsess_over_hosts smallint default 0,
  obsess_over_services smallint default 0,
  modified_host_attributes  int default 0,
  modified_service_attributes  int default 0,
  global_host_event_handler TEXT   default '',
  global_service_event_handler TEXT   default '',
  config_dump_in_progress smallint default 0,
  PRIMARY KEY  (programstatus_id),
  CONSTRAINT programstatus_instance_id UNIQUE (instance_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_runtimevariables
--

CREATE TABLE  icinga_runtimevariables (
  runtimevariable_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  varname varchar(64)   default '',
  varvalue TEXT   default '',
  PRIMARY KEY  (runtimevariable_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_scheduleddowntime
--

CREATE TABLE  icinga_scheduleddowntime (
  scheduleddowntime_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  downtime_type smallint default 0,
  object_id bigint  default 0,
  entry_time datetime default null,
  author_name varchar(64)   default '',
  comment_data TEXT   default '',
  internal_downtime_id bigint  default 0,
  triggered_by_id bigint  default 0,
  is_fixed smallint default 0,
  duration bigint default 0,
  scheduled_start_time datetime default null,
  scheduled_end_time datetime default null,
  was_started smallint default 0,
  actual_start_time datetime default null,
  actual_start_time_usec  int default 0,
  is_in_effect smallint default 0,
  trigger_time datetime default null,
  PRIMARY KEY  (scheduleddowntime_id),
  CONSTRAINT scheduleddowntime_instance_id UNIQUE (instance_id,object_id,entry_time,internal_downtime_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_servicechecks
--

CREATE TABLE  icinga_servicechecks (
  servicecheck_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  service_object_id bigint  default 0,
  check_type smallint default 0,
  current_check_attempt smallint default 0,
  max_check_attempts smallint default 0,
  state smallint default 0,
  state_type smallint default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  command_object_id bigint  default 0,
  command_args TEXT   default '',
  command_line TEXT   default '',
  timeout smallint default 0,
  early_timeout smallint default 0,
  execution_time float default '0',
  latency float default '0',
  return_code smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  perfdata TEXT   default '',
  PRIMARY KEY  (servicecheck_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_servicedependencies
--

CREATE TABLE  icinga_servicedependencies (
  servicedependency_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  service_object_id bigint  default 0,
  dependent_service_object_id bigint  default 0,
  dependency_type smallint default 0,
  inherits_parent smallint default 0,
  timeperiod_object_id bigint  default 0,
  fail_on_ok smallint default 0,
  fail_on_warning smallint default 0,
  fail_on_unknown smallint default 0,
  fail_on_critical smallint default 0,
  PRIMARY KEY  (servicedependency_id)
);

CREATE INDEX instance_id ON icinga_servicedependencies(instance_id,config_type,service_object_id,dependent_service_object_id,dependency_type,inherits_parent,fail_on_ok,fail_on_warning,fail_on_unknown,fail_on_critical);


-- --------------------------------------------------------

--
-- Table structure for table icinga_serviceescalations
--

CREATE TABLE  icinga_serviceescalations (
  serviceescalation_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  service_object_id bigint  default 0,
  timeperiod_object_id bigint  default 0,
  first_notification smallint default 0,
  last_notification smallint default 0,
  notification_interval float default '0',
  escalate_on_recovery smallint default 0,
  escalate_on_warning smallint default 0,
  escalate_on_unknown smallint default 0,
  escalate_on_critical smallint default 0,
  PRIMARY KEY  (serviceescalation_id),
  CONSTRAINT serviceescalations_instance_id UNIQUE (instance_id,config_type,service_object_id,timeperiod_object_id,first_notification,last_notification)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_serviceescalation_contactgroups
--

CREATE TABLE  icinga_serviceescalation_contactgroups (
  serviceescalation_contactgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  serviceescalation_id bigint  default 0,
  contactgroup_object_id bigint  default 0,
  PRIMARY KEY  (serviceescalation_contactgroup_id),
  CONSTRAINT serviceescalation_contactgroups_instance_id UNIQUE (serviceescalation_id,contactgroup_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_serviceescalation_contacts
--

CREATE TABLE  icinga_serviceescalation_contacts (
  serviceescalation_contact_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  serviceescalation_id bigint  default 0,
  contact_object_id bigint  default 0,
  PRIMARY KEY  (serviceescalation_contact_id),
  CONSTRAINT serviceescalation_contacts_instance_id UNIQUE (instance_id,serviceescalation_id,contact_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_servicegroups
--

CREATE TABLE  icinga_servicegroups (
  servicegroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  servicegroup_object_id bigint  default 0,
  alias TEXT   default '',
  notes TEXT   default NULL,
  notes_url TEXT   default NULL,
  action_url TEXT   default NULL,
  PRIMARY KEY  (servicegroup_id),
  CONSTRAINT servicegroups_instance_id UNIQUE (instance_id,config_type,servicegroup_object_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_servicegroup_members
--

CREATE TABLE  icinga_servicegroup_members (
  servicegroup_member_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  servicegroup_id bigint  default 0,
  service_object_id bigint  default 0,
  PRIMARY KEY  (servicegroup_member_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_services
--

CREATE TABLE  icinga_services (
  service_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  host_object_id bigint  default 0,
  service_object_id bigint  default 0,
  display_name varchar(255) default '',
  check_command_object_id bigint  default 0,
  check_command_args TEXT   default '',
  eventhandler_command_object_id bigint  default 0,
  eventhandler_command_args TEXT   default '',
  notification_timeperiod_object_id bigint  default 0,
  check_timeperiod_object_id bigint  default 0,
  failure_prediction_options varchar(64)   default '',
  check_interval float default '0',
  retry_interval float default '0',
  max_check_attempts smallint default 0,
  first_notification_delay float default '0',
  notification_interval float default '0',
  notify_on_warning smallint default 0,
  notify_on_unknown smallint default 0,
  notify_on_critical smallint default 0,
  notify_on_recovery smallint default 0,
  notify_on_flapping smallint default 0,
  notify_on_downtime smallint default 0,
  stalk_on_ok smallint default 0,
  stalk_on_warning smallint default 0,
  stalk_on_unknown smallint default 0,
  stalk_on_critical smallint default 0,
  is_volatile smallint default 0,
  flap_detection_enabled smallint default 0,
  flap_detection_on_ok smallint default 0,
  flap_detection_on_warning smallint default 0,
  flap_detection_on_unknown smallint default 0,
  flap_detection_on_critical smallint default 0,
  low_flap_threshold float default '0',
  high_flap_threshold float default '0',
  process_performance_data smallint default 0,
  freshness_checks_enabled smallint default 0,
  freshness_threshold smallint default 0,
  passive_checks_enabled smallint default 0,
  event_handler_enabled smallint default 0,
  active_checks_enabled smallint default 0,
  retain_status_information smallint default 0,
  retain_nonstatus_information smallint default 0,
  notifications_enabled smallint default 0,
  obsess_over_service smallint default 0,
  failure_prediction_enabled smallint default 0,
  notes TEXT   default '',
  notes_url TEXT   default '',
  action_url TEXT   default '',
  icon_image TEXT   default '',
  icon_image_alt TEXT   default '',
  PRIMARY KEY  (service_id),
  CONSTRAINT icinga_services_instance_id UNIQUE (instance_id,config_type,service_object_id)
);

CREATE INDEX service_object_id ON icinga_services(service_object_id);

-- --------------------------------------------------------

--
-- Table structure for table icinga_servicestatus
--

CREATE TABLE  icinga_servicestatus (
  servicestatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  service_object_id bigint  default 0,
  status_update_time datetime default null,
  output TEXT   default '',
  long_output TEXT  default '',
  perfdata TEXT   default '',
  check_source TEXT   default '',
  current_state smallint default 0,
  has_been_checked smallint default 0,
  should_be_scheduled smallint default 0,
  current_check_attempt smallint default 0,
  max_check_attempts smallint default 0,
  last_check datetime default null,
  next_check datetime default null,
  check_type smallint default 0,
  last_state_change datetime default null,
  last_hard_state_change datetime default null,
  last_hard_state smallint default 0,
  last_time_ok datetime default null,
  last_time_warning datetime default null,
  last_time_unknown datetime default null,
  last_time_critical datetime default null,
  state_type smallint default 0,
  last_notification datetime default null,
  next_notification datetime default null,
  no_more_notifications smallint default 0,
  notifications_enabled smallint default 0,
  problem_has_been_acknowledged smallint default 0,
  acknowledgement_type smallint default 0,
  current_notification_number smallint default 0,
  passive_checks_enabled smallint default 0,
  active_checks_enabled smallint default 0,
  event_handler_enabled smallint default 0,
  flap_detection_enabled smallint default 0,
  is_flapping smallint default 0,
  percent_state_change float default '0',
  latency float default '0',
  execution_time float default '0',
  scheduled_downtime_depth smallint default 0,
  failure_prediction_enabled smallint default 0,
  process_performance_data smallint default 0,
  obsess_over_service smallint default 0,
  modified_service_attributes  int default 0,
  event_handler TEXT   default '',
  check_command TEXT   default '',
  normal_check_interval float default '0',
  retry_check_interval float default '0',
  check_timeperiod_object_id bigint  default 0,
  is_reachable smallint default 0,
  PRIMARY KEY  (servicestatus_id)
);

CREATE INDEX object_id ON icinga_servicestatus(service_object_id);

-- --------------------------------------------------------

--
-- Table structure for table icinga_service_contactgroups
--

CREATE TABLE  icinga_service_contactgroups (
  service_contactgroup_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  service_id bigint  default 0,
  contactgroup_object_id bigint  default 0,
  PRIMARY KEY  (service_contactgroup_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_service_contacts
--

CREATE TABLE  icinga_service_contacts (
  service_contact_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  service_id bigint  default 0,
  contact_object_id bigint  default 0,
  PRIMARY KEY  (service_contact_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_statehistory
--

CREATE TABLE  icinga_statehistory (
  statehistory_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  state_time datetime default null,
  state_time_usec  int default 0,
  object_id bigint  default 0,
  state_change smallint default 0,
  state smallint default 0,
  state_type smallint default 0,
  current_check_attempt smallint default 0,
  max_check_attempts smallint default 0,
  last_state smallint default 0,
  last_hard_state smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  check_source varchar(255)  default NULL,
  PRIMARY KEY  (statehistory_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_systemcommands
--

CREATE TABLE  icinga_systemcommands (
  systemcommand_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  start_time datetime default null,
  start_time_usec  int default 0,
  end_time datetime default null,
  end_time_usec  int default 0,
  command_line TEXT   default '',
  timeout smallint default 0,
  early_timeout smallint default 0,
  execution_time float default '0',
  return_code smallint default 0,
  output TEXT   default '',
  long_output TEXT  default '',
  PRIMARY KEY  (systemcommand_id),
  CONSTRAINT systemcommands_instance_id UNIQUE (instance_id,start_time,start_time_usec)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_timeperiods
--

CREATE TABLE  icinga_timeperiods (
  timeperiod_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  config_type smallint default 0,
  timeperiod_object_id bigint  default 0,
  alias TEXT   default '',
  PRIMARY KEY  (timeperiod_id),
  CONSTRAINT timeperiods_instance_id UNIQUE (instance_id,config_type,timeperiod_object_id)
);


-- --------------------------------------------------------

--
-- Table structure for table icinga_timeperiod_timeranges
--

CREATE TABLE  icinga_timeperiod_timeranges (
  timeperiod_timerange_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  timeperiod_id bigint  default 0,
  day smallint default 0,
  start_sec  int default 0,
  end_sec  int default 0,
  PRIMARY KEY  (timeperiod_timerange_id)
);


-- --------------------------------------------------------
-- Icinga 2 specific schema extensions
-- --------------------------------------------------------

--
-- Table structure for table icinga_endpoints
--

CREATE TABLE  icinga_endpoints (
  endpoint_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  endpoint_object_id bigint  DEFAULT '0',
  config_type smallint DEFAULT '0',
  [identity] varchar(255) DEFAULT NULL,
  node varchar(255) DEFAULT NULL,
  PRIMARY KEY  (endpoint_id)
);

-- --------------------------------------------------------

--
-- Table structure for table icinga_endpointstatus
--

CREATE TABLE  icinga_endpointstatus (
  endpointstatus_id bigint  NOT NULL IDENTITY,
  instance_id bigint  default 0,
  endpoint_object_id bigint  DEFAULT '0',
  status_update_time datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  [identity] varchar(255) DEFAULT NULL,
  node varchar(255) DEFAULT NULL,
  is_connected smallint,
  PRIMARY KEY  (endpointstatus_id)
);


ALTER TABLE icinga_servicestatus ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_hoststatus ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_contactstatus ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_programstatus ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_comments ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_scheduleddowntime ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_runtimevariables ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_customvariablestatus ADD endpoint_object_id bigint default NULL;

ALTER TABLE icinga_acknowledgements ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_commenthistory ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_contactnotifications ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_downtimehistory ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_eventhandlers ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_externalcommands ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_flappinghistory ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_hostchecks ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_logentries ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_notifications ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_processevents ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_servicechecks ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_statehistory ADD endpoint_object_id bigint default NULL;
ALTER TABLE icinga_systemcommands ADD endpoint_object_id bigint default NULL;

-- -----------------------------------------
-- add index (delete)
-- -----------------------------------------

-- for periodic delete 
-- instance_id and
-- SYSTEMCOMMANDS, SERVICECHECKS, HOSTCHECKS, EVENTHANDLERS  => start_time
-- EXTERNALCOMMANDS => entry_time

-- instance_id
CREATE INDEX systemcommands_i_id_idx on icinga_systemcommands(instance_id);
CREATE INDEX servicechecks_i_id_idx on icinga_servicechecks(instance_id);
CREATE INDEX hostchecks_i_id_idx on icinga_hostchecks(instance_id);
CREATE INDEX eventhandlers_i_id_idx on icinga_eventhandlers(instance_id);
CREATE INDEX externalcommands_i_id_idx on icinga_externalcommands(instance_id);

-- time
CREATE INDEX systemcommands_time_id_idx on icinga_systemcommands(start_time);
CREATE INDEX servicechecks_time_id_idx on icinga_servicechecks(start_time);
CREATE INDEX hostchecks_time_id_idx on icinga_hostchecks(start_time);
CREATE INDEX eventhandlers_time_id_idx on icinga_eventhandlers(start_time);
CREATE INDEX externalcommands_time_id_idx on icinga_externalcommands(entry_time);


-- for starting cleanup - referenced in dbhandler.c:882
-- instance_id only

-- realtime data
CREATE INDEX programstatus_i_id_idx on icinga_programstatus(instance_id);
CREATE INDEX hoststatus_i_id_idx on icinga_hoststatus(instance_id);
CREATE INDEX servicestatus_i_id_idx on icinga_servicestatus(instance_id);
CREATE INDEX contactstatus_i_id_idx on icinga_contactstatus(instance_id);
CREATE INDEX comments_i_id_idx on icinga_comments(instance_id);
CREATE INDEX scheduleddowntime_i_id_idx on icinga_scheduleddowntime(instance_id);
CREATE INDEX runtimevariables_i_id_idx on icinga_runtimevariables(instance_id);
CREATE INDEX customvariablestatus_i_id_idx on icinga_customvariablestatus(instance_id);

-- config data
CREATE INDEX configfiles_i_id_idx on icinga_configfiles(instance_id);
CREATE INDEX configfilevariables_i_id_idx on icinga_configfilevariables(instance_id);
CREATE INDEX customvariables_i_id_idx on icinga_customvariables(instance_id);
CREATE INDEX commands_i_id_idx on icinga_commands(instance_id);
CREATE INDEX timeperiods_i_id_idx on icinga_timeperiods(instance_id);
CREATE INDEX timeperiod_timeranges_i_id_idx on icinga_timeperiod_timeranges(instance_id);
CREATE INDEX contactgroups_i_id_idx on icinga_contactgroups(instance_id);
CREATE INDEX contactgroup_members_i_id_idx on icinga_contactgroup_members(instance_id);
CREATE INDEX hostgroups_i_id_idx on icinga_hostgroups(instance_id);
CREATE INDEX hostgroup_members_i_id_idx on icinga_hostgroup_members(instance_id);
CREATE INDEX servicegroups_i_id_idx on icinga_servicegroups(instance_id);
CREATE INDEX servicegroup_members_i_id_idx on icinga_servicegroup_members(instance_id);
CREATE INDEX hostesc_i_id_idx on icinga_hostescalations(instance_id);
CREATE INDEX hostesc_contacts_i_id_idx on icinga_hostescalation_contacts(instance_id);
CREATE INDEX serviceesc_i_id_idx on icinga_serviceescalations(instance_id);
CREATE INDEX serviceesc_contacts_i_id_idx on icinga_serviceescalation_contacts(instance_id);
CREATE INDEX hostdependencies_i_id_idx on icinga_hostdependencies(instance_id);
CREATE INDEX contacts_i_id_idx on icinga_contacts(instance_id);
CREATE INDEX contact_addresses_i_id_idx on icinga_contact_addresses(instance_id);
CREATE INDEX contact_notifcommands_i_id_idx on icinga_contact_notificationcommands(instance_id);
CREATE INDEX hosts_i_id_idx on icinga_hosts(instance_id);
CREATE INDEX host_parenthosts_i_id_idx on icinga_host_parenthosts(instance_id);
CREATE INDEX host_contacts_i_id_idx on icinga_host_contacts(instance_id);
CREATE INDEX services_i_id_idx on icinga_services(instance_id);
CREATE INDEX service_contacts_i_id_idx on icinga_service_contacts(instance_id);
CREATE INDEX service_contactgroups_i_id_idx on icinga_service_contactgroups(instance_id);
CREATE INDEX host_contactgroups_i_id_idx on icinga_host_contactgroups(instance_id);
CREATE INDEX hostesc_cgroups_i_id_idx on icinga_hostescalation_contactgroups(instance_id);
CREATE INDEX serviceesc_cgroups_i_id_idx on icinga_serviceescalation_contactgroups(instance_id);

-- -----------------------------------------
-- more index stuff (WHERE clauses)
-- -----------------------------------------

-- hosts
CREATE INDEX hosts_host_object_id_idx on icinga_hosts(host_object_id);

-- hoststatus
CREATE INDEX hoststatus_stat_upd_time_idx on icinga_hoststatus(status_update_time);
CREATE INDEX hoststatus_current_state_idx on icinga_hoststatus(current_state);
CREATE INDEX hoststatus_check_type_idx on icinga_hoststatus(check_type);
CREATE INDEX hoststatus_state_type_idx on icinga_hoststatus(state_type);
CREATE INDEX hoststatus_last_state_chg_idx on icinga_hoststatus(last_state_change);
CREATE INDEX hoststatus_notif_enabled_idx on icinga_hoststatus(notifications_enabled);
CREATE INDEX hoststatus_problem_ack_idx on icinga_hoststatus(problem_has_been_acknowledged);
CREATE INDEX hoststatus_act_chks_en_idx on icinga_hoststatus(active_checks_enabled);
CREATE INDEX hoststatus_pas_chks_en_idx on icinga_hoststatus(passive_checks_enabled);
CREATE INDEX hoststatus_event_hdl_en_idx on icinga_hoststatus(event_handler_enabled);
CREATE INDEX hoststatus_flap_det_en_idx on icinga_hoststatus(flap_detection_enabled);
CREATE INDEX hoststatus_is_flapping_idx on icinga_hoststatus(is_flapping);
CREATE INDEX hoststatus_p_state_chg_idx on icinga_hoststatus(percent_state_change);
CREATE INDEX hoststatus_latency_idx on icinga_hoststatus(latency);
CREATE INDEX hoststatus_ex_time_idx on icinga_hoststatus(execution_time);
CREATE INDEX hoststatus_sch_downt_d_idx on icinga_hoststatus(scheduled_downtime_depth);

-- services
CREATE INDEX services_host_object_id_idx on icinga_services(host_object_id);

-- servicestatus
CREATE INDEX srvcstatus_stat_upd_time_idx on icinga_servicestatus(status_update_time);
CREATE INDEX srvcstatus_current_state_idx on icinga_servicestatus(current_state);
CREATE INDEX srvcstatus_check_type_idx on icinga_servicestatus(check_type);
CREATE INDEX srvcstatus_state_type_idx on icinga_servicestatus(state_type);
CREATE INDEX srvcstatus_last_state_chg_idx on icinga_servicestatus(last_state_change);
CREATE INDEX srvcstatus_notif_enabled_idx on icinga_servicestatus(notifications_enabled);
CREATE INDEX srvcstatus_problem_ack_idx on icinga_servicestatus(problem_has_been_acknowledged);
CREATE INDEX srvcstatus_act_chks_en_idx on icinga_servicestatus(active_checks_enabled);
CREATE INDEX srvcstatus_pas_chks_en_idx on icinga_servicestatus(passive_checks_enabled);
CREATE INDEX srvcstatus_event_hdl_en_idx on icinga_servicestatus(event_handler_enabled);
CREATE INDEX srvcstatus_flap_det_en_idx on icinga_servicestatus(flap_detection_enabled);
CREATE INDEX srvcstatus_is_flapping_idx on icinga_servicestatus(is_flapping);
CREATE INDEX srvcstatus_p_state_chg_idx on icinga_servicestatus(percent_state_change);
CREATE INDEX srvcstatus_latency_idx on icinga_servicestatus(latency);
CREATE INDEX srvcstatus_ex_time_idx on icinga_servicestatus(execution_time);
CREATE INDEX srvcstatus_sch_downt_d_idx on icinga_servicestatus(scheduled_downtime_depth);

-- hostchecks
CREATE INDEX hostchks_h_obj_id_idx on icinga_hostchecks(host_object_id);

-- servicechecks
CREATE INDEX servicechks_s_obj_id_idx on icinga_servicechecks(service_object_id);

-- objects
CREATE INDEX objects_objtype_id_idx ON icinga_objects(objecttype_id);
CREATE INDEX objects_name1_idx ON icinga_objects(name1);
CREATE INDEX objects_name2_idx ON icinga_objects(name2);
CREATE INDEX objects_inst_id_idx ON icinga_objects(instance_id);

-- instances
-- CREATE INDEX instances_name_idx on icinga_instances(instance_name);

-- logentries
-- CREATE INDEX loge_instance_id_idx on icinga_logentries(instance_id);
-- #236
CREATE INDEX loge_time_idx on icinga_logentries(logentry_time);
-- CREATE INDEX loge_data_idx on icinga_logentries(logentry_data);
CREATE INDEX loge_inst_id_time_idx on icinga_logentries (instance_id ASC, logentry_time DESC);

-- commenthistory
-- CREATE INDEX c_hist_instance_id_idx on icinga_logentries(instance_id);
-- CREATE INDEX c_hist_c_time_idx on icinga_logentries(comment_time);
-- CREATE INDEX c_hist_i_c_id_idx on icinga_logentries(internal_comment_id);

-- downtimehistory
-- CREATE INDEX d_t_hist_nstance_id_idx on icinga_downtimehistory(instance_id);
-- CREATE INDEX d_t_hist_type_idx on icinga_downtimehistory(downtime_type);
-- CREATE INDEX d_t_hist_object_id_idx on icinga_downtimehistory(object_id);
-- CREATE INDEX d_t_hist_entry_time_idx on icinga_downtimehistory(entry_time);
-- CREATE INDEX d_t_hist_sched_start_idx on icinga_downtimehistory(scheduled_start_time);
-- CREATE INDEX d_t_hist_sched_end_idx on icinga_downtimehistory(scheduled_end_time);

-- scheduleddowntime
-- CREATE INDEX sched_d_t_downtime_type_idx on icinga_scheduleddowntime(downtime_type);
-- CREATE INDEX sched_d_t_object_id_idx on icinga_scheduleddowntime(object_id);
-- CREATE INDEX sched_d_t_entry_time_idx on icinga_scheduleddowntime(entry_time);
-- CREATE INDEX sched_d_t_start_time_idx on icinga_scheduleddowntime(scheduled_start_time);
-- CREATE INDEX sched_d_t_end_time_idx on icinga_scheduleddowntime(scheduled_end_time);

-- statehistory
CREATE INDEX statehist_i_id_o_id_s_ty_s_ti on icinga_statehistory(instance_id, object_id, state_type, state_time);
--#2274
create index statehist_state_idx on icinga_statehistory(object_id,state);


-- Icinga Web Notifications
CREATE INDEX notification_idx ON icinga_notifications(notification_type, object_id, start_time);
CREATE INDEX notification_object_id_idx ON icinga_notifications(object_id);
CREATE INDEX contact_notification_idx ON icinga_contactnotifications(notification_id, contact_object_id);
CREATE INDEX contacts_object_id_idx ON icinga_contacts(contact_object_id);
CREATE INDEX contact_notif_meth_notif_idx ON icinga_contactnotificationmethods(contactnotification_id, command_object_id);
CREATE INDEX command_object_idx ON icinga_commands(object_id); 
CREATE INDEX services_combined_object_idx ON icinga_services(service_object_id, host_object_id);


-- #2618
CREATE INDEX cntgrpmbrs_cgid_coid ON icinga_contactgroup_members (contactgroup_id,contact_object_id);
CREATE INDEX hstgrpmbrs_hgid_hoid ON icinga_hostgroup_members (hostgroup_id,host_object_id);
CREATE INDEX hstcntgrps_hid_cgoid ON icinga_host_contactgroups (host_id,contactgroup_object_id);
CREATE INDEX hstprnthsts_hid_phoid ON icinga_host_parenthosts (host_id,parent_host_object_id);
CREATE INDEX runtimevars_iid_varn ON icinga_runtimevariables (instance_id,varname);
CREATE INDEX sgmbrs_sgid_soid ON icinga_servicegroup_members (servicegroup_id,service_object_id);
CREATE INDEX scgrps_sid_cgoid ON icinga_service_contactgroups (service_id,contactgroup_object_id);
CREATE INDEX tperiod_tid_d_ss_es ON icinga_timeperiod_timeranges (timeperiod_id,day,start_sec,end_sec);

-- #3649
CREATE INDEX sla_idx_sthist ON icinga_statehistory (object_id, state_time DESC);
CREATE INDEX sla_idx_dohist ON icinga_downtimehistory (object_id, actual_start_time, actual_end_time);
CREATE INDEX sla_idx_obj ON icinga_objects (objecttype_id, is_active, name1);

-- #4985
CREATE INDEX commenthistory_delete_idx ON icinga_commenthistory (instance_id, comment_time, internal_comment_id);

-- -----------------------------------------
-- set dbversion
-- -----------------------------------------
if exists( select version from icinga_dbversion where name = 'idoutils' )
    update icinga_dbversion set version = '1.13.0', modify_time=GETUTCDATE() where name = 'idoutils'
else
    insert into icinga_dbversion (name, version, create_time, modify_time)
    values ('idoutils', '1.13.0', GETUTCDATE(), GETUTCDATE())
;
