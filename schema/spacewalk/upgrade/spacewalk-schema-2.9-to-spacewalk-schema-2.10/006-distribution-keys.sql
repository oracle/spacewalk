-- Fedora 30
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       'CFC659B9',
       lookup_package_key_type('gpg'),
       lookup_package_provider('Fedora')
 FROM dual
WHERE NOT EXISTS (
     SELECT *
       FROM rhnpackagekey pk
      WHERE pk.key_id = 'CFC659B9'
);

-- Fedora 31
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       '3C3359C4',
        lookup_package_key_type('gpg'),
        lookup_package_provider('Fedora')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = '3C3359C4'
);

-- CentOS 8
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       '05b555b38483c65d',
       lookup_package_key_type('gpg'),
       lookup_package_provider('CentOS')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id =  '05b555b38483c65d'
);

-- Spacewalk 2.10
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       '3ae9b50430912c76',
       lookup_package_key_type('gpg'),
       lookup_package_provider('Spacewalk')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = '3ae9b50430912c76'
);

INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       '770ce53ebc2e6843',
       lookup_package_key_type('gpg'),
       lookup_package_provider('Spacewalk')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = '770ce53ebc2e6843'
);

-- Spacewalk nightly
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       'e481344adba67ea3',
       lookup_package_key_type('gpg'),
       lookup_package_provider('Spacewalk')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = 'e481344adba67ea3'
);

INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       'd4b984391b9881e5',
       lookup_package_key_type('gpg'),
       lookup_package_provider('Spacewalk')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = 'd4b984391b9881e5'
);

-- EPEL 8
INSERT INTO rhnpackagekey
            (id,
             key_id,
             key_type_id,
             provider_id)
SELECT sequence_nextval('rhn_pkey_id_seq'),
       '21ea45ab2f86d6a1',
       lookup_package_key_type('gpg'),
       lookup_package_provider('EPEL')
 FROM dual
WHERE NOT EXISTS (
      SELECT *
        FROM rhnpackagekey pk
       WHERE pk.key_id = '21ea45ab2f86d6a1'
);
