use utf8;
package BookWeb::Schema::Result::Book;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

BookWeb::Schema::Result::Book

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<book>

=cut

__PACKAGE__->table("book");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 isbn

  data_type: 'char'
  is_nullable: 1
  size: 10

=head2 author

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 started

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 ended

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 image_url

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "isbn",
  { data_type => "char", is_nullable => 1, size => 10 },
  "author",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "started",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "ended",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "image_url",
  { data_type => "varchar", is_nullable => 1, size => 250 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<BookWeb::Schema::Result::Author>

=cut

__PACKAGE__->belongs_to(
  "author",
  "BookWeb::Schema::Result::Author",
  { id => "author" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-03-29 16:32:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LaMx4W9VYwOD9klNmXroRQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
