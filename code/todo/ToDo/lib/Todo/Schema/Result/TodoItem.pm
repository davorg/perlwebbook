use utf8;
package Todo::Schema::Result::TodoItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Todo::Schema::Result::TodoItem

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<todo_item>

=cut

__PACKAGE__->table("todo_item");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 250

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 priority

  data_type: 'integer'
  default_value: 5
  is_nullable: 0

=head2 due_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 250 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "priority",
  { data_type => "integer", default_value => 5, is_nullable => 0 },
  "due_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-07-09 18:04:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NR76utXm8aqvuaRKKUD3Gw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
