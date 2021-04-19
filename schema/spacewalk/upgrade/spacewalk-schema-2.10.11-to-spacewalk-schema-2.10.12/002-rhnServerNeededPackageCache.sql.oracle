--
-- Copyright (C) 2020 Oracle and/or its affiliates. All rights reserved.
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
CREATE OR REPLACE VIEW
rhnServerNeededPackageCache
(
    server_id,
    package_id,
    errata_id
)
AS
SELECT
	SNC.server_id,
	SNC.package_id,
	max(SNC.errata_id) AS errata_id
FROM
	rhnPackageEVR PE,
	rhnPackage P,
	rhnServerNeededCache SNC
LEFT OUTER JOIN rhnErrata E ON SNC.errata_id = E.id
WHERE
	SNC.package_id = P.id
	AND P.evr_id = PE.id
	AND ((lower(pe.release) NOT LIKE '%module+%')
		OR (lower(pe.release) LIKE '%module+%'
			AND regexp_substr(E.synopsis, '[^ ]+:[^ ]+') IN (
			SELECT
				module_stream
			FROM
				rhnservermodulesview
			WHERE
				server_id = SNC.server_id)))
GROUP BY
	snc.server_id,
	snc.package_id;
