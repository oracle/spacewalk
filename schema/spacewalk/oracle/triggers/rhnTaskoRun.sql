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

CREATE OR REPLACE TRIGGER
RHN_TASKORUN_MV_UPD_MOD_TRIG 
AFTER UPDATE OF end_time, status ON RHNTASKORUN
FOR EACH ROW
DECLARE
    -- Allow DBMS_MVIEW.REFRESH() to commit
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  -- Trigger a refresh of MVs after Taskomatic has completed Errata and YUM metadata computation jobs
  -- These are triggered after client report home, repo-sync, or via spacecmd
  -- The underlying procs commit in chunks to avoid contention, but we want to refresh when the whole job is done

  IF (:NEW.std_output_path LIKE '%errata-cache%' OR :NEW.std_output_path LIKE '%channel-repodata%')
  AND (:OLD.end_time IS NULL AND :NEW.end_time IS NOT NULL)
  AND (:OLD.status = 'RUNNING' AND :NEW.status = 'FINISHED')
  THEN
        DBMS_MVIEW.REFRESH(list => 'RHNSERVERMODULESVIEW, RHNSERVERNEEDEDPACKAGECACHE, RHNSERVEROVERVIEW',
                           method => '???', -- Force refresh (fast, failover to complete)
                           parallelism => 3,
                           nested => TRUE); -- Refresh in dependency order
  END IF;
END;
/
show errors
