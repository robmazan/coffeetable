CREATE TABLE media (
    id serial PRIMARY KEY,
    owner text NOT NULL,
    path text UNIQUE,
    hash text UNIQUE,
    date_taken timestamp,
    mime_type text NOT NULL,
    width int NOT NULL,
    height int NOT NULL,
    lat float,
    long float,
    metadata jsonb
);

CREATE TABLE album_contents (
    media_id int REFERENCES media(id),
    album_id text NOT NULL,
    item_order int
);
