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

CREATE MATERIALIZED VIEW RHNSERVEROVERVIEW
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
AS
SELECT *
FROM RHNSERVEROVERVIEW_BACKING;


CREATE INDEX RSO_SID_IDX ON RHNSERVEROVERVIEW (SERVER_ID);
