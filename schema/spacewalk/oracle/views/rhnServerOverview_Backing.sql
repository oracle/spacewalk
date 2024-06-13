--
-- Copyright (C) 2024 Oracle and/or its affiliates.
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, version 2
--
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
-- 02110-1301, USA.
--

CREATE OR REPLACE VIEW RHNSERVEROVERVIEW_BACKING ("ORG_ID", "SERVER_ID", "SERVER_NAME", "MODIFIED", "SERVER_ADMINS", "GROUP_COUNT", "CHANNEL_ID", "CHANNEL_LABELS", "HISTORY_COUNT", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "OUTDATED_PACKAGES", "CONFIG_FILES_WITH_DIFFERENCES", "UNIQUE_CRASH_COUNT", "TOTAL_CRASH_COUNT", "LAST_CHECKIN_DAYS_AGO", "LAST_CHECKIN", "PENDING_UPDATES", "OS", "RELEASE", "SERVER_ARCH_NAME", "LOCKED") AS 
  select
    s.org_id, s.id, s.name, s.modified,
    ( select count(user_id) from rhnUserServerPerms ap
      where server_id = s.id ),
    ( select count(server_group_id) from rhnVisibleServerGroupMembers
      where server_id = s.id ),
    ( select C.id
        from rhnChannel C,
	     rhnServerChannel SC
       where SC.server_id = S.id
         and SC.channel_id = C.id
	 and C.parent_channel IS NULL),
    coalesce(( select C.name
        from rhnChannel C,
	     rhnServerChannel SC
       where SC.server_id = S.id
         and SC.channel_id = C.id
	 and C.parent_channel IS NULL), '(none)'),
    ( select count(id) from rhnServerHistory
      where
            server_id = S.id),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Security Advisory'),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Bug Fix Advisory'),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Product Enhancement Advisory'),
    ( select count(distinct p.name_id) from rhnPackage p, rhnServerNeededPackageCache snpc
      where
             snpc.server_id = S.id
	 and p.id = snpc.package_id
	 ),
    ( select count(*)
        from rhnActionConfigRevision ACR
             INNER JOIN rhnActionConfigRevisionResult ACRR on ACR.id = ACRR.action_config_revision_id
       where ACR.server_id = S.id
         and ACR.action_id = (
              select MAX(rA.id)
                from rhnAction rA
                     INNER JOIN rhnServerAction rSA on rSA.action_id = rA.id
                     INNER JOIN rhnActionStatus rAS on rAS.id = rSA.status
                     INNER JOIN rhnActionType rAT on rAT.id = rA.action_type
               where rSA.server_id = S.id
                 and rAS.name in ('Completed', 'Failed')
                 and rAT.label = 'configfiles.diff'
         )
         and ACR.failure_id is null
         and ACRR.result is not null
        ),
    ( select unique_count from rhnServerCrashCount where server_id = S.id ),
    ( select total_count from rhnServerCrashCount where server_id = S.id ),
    ( select date_diff_in_days(checkin, current_timestamp) from rhnServerInfo where server_id = S.id ),
    ( select TO_CHAR(checkin, 'YYYY-MM-DD HH24:MI:SS') from rhnServerInfo where server_id = S.id ),
    ( select count(1)
        from rhnServerAction
       where server_id = S.id
         and status in (0, 1)),
    os,
    release,
    ( select name from rhnServerArch where id = s.server_arch_id),
    coalesce((select 1 from rhnServerLock SL WHERE SL.server_id = S.id), 0)
from
    rhnServer S
;
