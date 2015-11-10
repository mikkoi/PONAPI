package Test::PONAPI::DAO::Repository::MockDB::Loader;
use Moose;

use DBI;

has dbd => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { 'DBI:SQLite:dbname=MockDB.db' },
);

has dbh => (
    is      => 'ro',
    isa     => 'DBI::db',
    lazy    => 1,
    builder => '_build_dbh',
);

sub _build_dbh {
    my $self = shift;
    DBI->connect( $self->dbd, '', '', { RaiseError => 1 } )
        or die $DBI::errstr;
}

sub load {
    my $self = shift;

    $self->dbh->do($_) for
        q< DROP TABLE IF EXISTS articles; >,
        q< CREATE TABLE IF NOT EXISTS articles (
             id            INTEGER     PRIMARY KEY AUTOINCREMENT,
             title         CHAR(64)    NOT NULL,
             body          TEXT        NOT NULL,
             created       DATETIME    NOT NULL   DEFAULT CURRENT_TIMESTAMP,
             updated       DATETIME    NOT NULL   DEFAULT CURRENT_TIMESTAMP,
             status        CHAR(10)    NOT NULL   DEFAULT "pending approval" ); >,

        q< INSERT INTO articles (title, body, created, updated, status) VALUES
             ("JSON API paints my bikeshed!", "The shortest article. Ever.",
              "2015-05-22 14:56:29", "2015-05-22 14:56:29", "ok" ),
             ("A second title", "The 2nd shortest article. Ever.",
              "2015-06-22 14:56:29", "2015-06-22 14:56:29", "ok" ),
             ("a third one", "The 3rd shortest article. Ever.",
              "2015-07-22 14:56:29", "2015-07-22 14:56:29", "pending approval" ); >,

        q< DROP TABLE IF EXISTS people; >,
        q< CREATE TABLE IF NOT EXISTS people (
             id            INTEGER     PRIMARY KEY,
             name          CHAR(64)    NOT NULL   DEFAULT "anonymous",
             age           INTEGER     NOT NULL   DEFAULT "100",
             gender        CHAR(10)    NOT NULL   DEFAULT "unknown" ); >,

        q< INSERT INTO people (id, name, age, gender) VALUES
             (42, "John",  80, "male"),
             (88, "Jimmy", 18, "male"),
             (91, "Diana", 30, "female") >,

        q< DROP TABLE IF EXISTS rel_articles_people; >,
        q< CREATE TABLE IF NOT EXISTS rel_articles_people (
             id_articles   INTEGER     UNIQUE     NOT NULL,
             id_people     INTEGER     UNIQUE     NOT NULL ); >,

        q< INSERT INTO rel_articles_people (id_articles, id_people) VALUES
             (1, 42),
             (2, 88),
             (3, 91) >,

        q< DROP TABLE IF EXISTS comments; >,
        q< CREATE TABLE IF NOT EXISTS comments (
             id            INTEGER     PRIMARY KEY,
             body          TEXT        NOT NULL DEFAULT "" ); >,

        q< INSERT INTO comments (id, body) VALUES
             (5,  "First!"),
             (12, "I like XML better") >,

        q< DROP TABLE IF EXISTS rel_articles_comments; >,
        q< CREATE TABLE IF NOT EXISTS rel_articles_comments (
             id_articles   INTEGER     NOT NULL,
             id_comments   INTEGER     UNIQUE     NOT NULL ); >,

        q< INSERT INTO rel_articles_comments (id_articles, id_comments) VALUES
             (2, 5),
             (2, 12) >;
}

__PACKAGE__->meta->make_immutable;

no Moose; 1;
__END__