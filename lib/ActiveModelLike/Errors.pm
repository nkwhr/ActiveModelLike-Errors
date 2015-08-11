package ActiveModelLike::Errors;
use 5.008001;
use strict;
use warnings;
use Carp;

our $VERSION = '0.02';

sub new {
    my ($class) = @_;
    bless { messages => {} }, $class
}

sub messages { $_[0]->{messages}; }

sub clear { $_[0]->{messages} = {}; }

sub include {
    my ($self, $attribute) = @_;
    $self->{messages}->{$attribute} ? 1 : 0;
}

sub has_key { $_[0]->include($_[1]); }

sub get {
    my ($self, $key) = @_;
    $self->messages->{$key};
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{messages}->{$key} = $value;
}

sub delete {
    my ($self, $key) = @_;
    CORE::delete $self->{messages}->{$key};
}

sub each {
    my ($self, $coderef) = @_;

    Carp::croak 'Argument must be a subroutine reference'
            if ref($coderef) ne 'CODE';

    for my $attribute (CORE::keys %{$self->messages}) {
        for my $error (@{$self->messages->{$attribute}}) {
            $coderef->($attribute, $error);
        }
    }
}

sub size {
    my ($self) = @_;
    scalar(map { @$_ } @{$self->values});
}

sub count { $_[0]->size; }

sub values {
    my @values = CORE::values %{$_[0]->messages};
    return \@values;
}

sub keys {
    my @keys = sort(CORE::keys %{$_[0]->messages});
    return \@keys;
}

sub is_empty { $_[0]->size == 0 ? 1 : 0; }

sub is_blank { $_[0]->is_empty; }

sub to_hash {
    my ($self, $full_messages) = @_;
    $full_messages ||= 0;

    my $messages = {};

    if ($full_messages == 1) {
        for my $attribute (sort(CORE::keys %{$self->messages})) {
            @{$messages->{$attribute}} = map {
                $self->full_message($attribute, $_)
            } @{$self->messages->{$attribute}};
        }
    } else {
        $messages = $self->messages;
    }

    return $messages;
}

sub add {
    my ($self, $attribute, $message, $options) = @_;
    $message ||= 'is invalid';
    $options ||= {};
    $message = $self->_normalize_message($message);

    if (my $exception = $options->{strict}) {
        $exception = 'Strict validation failed' if $exception eq 1;
        Carp::croak("$exception: " . $self->full_message($attribute, $message));
    }

    push @{$self->messages->{$attribute}}, $message;
    return $self->messages->{$attribute};
}

sub is_added {
    my ($self, $attribute, $message) = @_;
    $message ||= 'is invalid';
    $message = $self->_normalize_message($message);

    grep { $_ eq $message } @{$self->messages->{$attribute}};
}

sub full_messages {
    my ($self) = @_;
    my @full_messages;

    for my $attribute (sort(CORE::keys %{$self->messages})) {
        for my $message (@{$self->messages->{$attribute}}) {
            push @full_messages, $self->full_message($attribute, $message);
        }
    }

    return \@full_messages;
}

sub to_array { $_[0]->full_messages; }

sub full_messages_for {
    my ($self, $attribute) = @_;

    my @messages = map {
        $self->full_message($attribute, $_);
    } @{$self->messages->{$attribute}};

    return \@messages;
}

sub full_message {
    my ($self, $attribute, $message) = @_;

    return $message if ($attribute eq 'base');

    my $attr_name = ucfirst $attribute;
    $attr_name =~ tr/\./\_/;
    $attr_name =~ s/\_/ /g;

    return "$attr_name $message";
}

sub _normalize_message {
    my ($self, $message) = @_;
    ref $message eq 'CODE' ? $message->() : $message;
}

1;
__END__

=encoding utf-8

=head1 NAME

ActiveModelLike::Errors - A Perl port of ActiveModel::Errors

=head1 SYNOPSIS

    use ActiveModelLike::Errors;

    my $errors = ActiveModelLike::Errors->new;

    $errros->add('age', 'is invalid');
    $errros->add('name', 'can not be empty');

    $errors->is_empty;      # 0
    $errors->messages;      # { age => ['is invalid'], name => ['can not be empty'] }
    $errors->full_messages; # ['Age is invalid', 'Name can not be empty']

=head1 DESCRIPTION

This is a port of Rails' ActiveModel::Errors to Perl, which provides a modified Hash that you can include in your object for handling error messages.

Due to lack of other related modules (e.g. ActiveModel::Validations, ActiveModel::Translation and etc.), it is not fully comaptible with the original, but may be useful in some cases if you are familiar with its interface.

=head1 METHODS

=head2 add

Adds error message for the attribute and returns its error messages.
More than one message can be set on the same attribute.
If no message is supplied, "is invalid" will be set by default.

    $errors->add('name');                     # ['is invalid']
    $errors->add('name', 'can not be empty'); # ['is invalid', 'can not be empty']

Message also can be a subroutine reference.

    $errors->add('age', sub {
        # do something
        # return result as a message
    });

If the strict option is enabled, it will die and croak an error instead of adding them.
An option can also be a custom message.

    $errors->add('name', 'is invalid', { strict => 1 });
    # Dies with a message "Strict validation failed: Name is invalid"

    $errors->add('name', 'is invalid', { strict => 'Custom Exception' });
    # Dies with a message "Custom Exception: Name is invalid"

If the error is not associated with a specific attribute, it should be set to "base".

    $errors->add('base', 'something went wrong');
    $errors->messages; # { base => ['something went wrong'] }

=head2 clear

Clear the error messages.

    $errors->full_messages; # ['Name is invalid']
    $errors->clear;
    $errors->full_messages; # {}

=head2 count

Alias for L<"size">.

=head2 delete

Delete messages for the attribute. Returns the deleted messages.

    $errors->get('name');    # ['is invalid']
    $errors->delete('name'); # ['is invalid']
    $errors->get('name');    # undef

=head2 each

Iterates through each attribute/message pair in the error messages hash.

    $errors->add('name', 'can not be empty');
    $errors->add('name', 'is invalid');

    $errors->each(sub {
        my ($attribute, $message) = @_;
        # do_something
    });

=head2 full_message

Returns a full message for a given attribute.

    $errors->full_message('name', 'is invalid'); # 'Name is invalid'

=head2 full_messages

Returns all the full error messages in an array.

    $errors->add('age', 'can not be empty');
    $errors->add('name', 'is invalid');
    $errors->add('name', 'can not be empty');
    $errors->full_messages; # ['Age can not be empty', 'Name is invalid', 'Name can not be empty']

=head2 full_messages_for

Returns all the full error messages for a given attribute.

    $errors->add('name', 'is invalid');
    $errors->add('name', 'can not be empty');
    $errors->full_messages_for('name'); # ['Name is invalid', 'Name can not be empty']
    $errors->full_messages_for('age');  # []

=head2 get

Get messages for the given attribute.

    $errors->messages;    # { name => ['is invalid'] }
    $errors->get('name'); # ['is invalid']
    $errors->get('age');  # undef

=head2 has_key

Alias for L<"include">.

=head2 include

Returns "1" if the error messages include an error for the given attribute.
Otherwise returns "0".

    $errors->messages;        # { name => ['is invalid'] }
    $errors->include('name'); # 1
    $errors->include('age');  # 0

=head2 is_added

Returns "1" if an error on the attribute with the given message is present.
Otherwise returns "0".

    $errors->add('name', 'is invalid');
    $errors->is_added('name', 'is invalid');       # 1
    $errors->is_added('name', 'can not be empty'); # 0

=head2 is_blank

Alias for L<"is_empty">.

=head2 is_empty

Returns "1" if no errors are found. Otherwise returns "0".

    $errors->messages; # { name => 'can not be empty' }
    $errors->is_empty; # 0
    $errors->clear;
    $errors->is_empty: # 1

=head2 keys

Returns all message attributes.

    $errors->messages; # { age => ['is invalid'], name => ['can not be empty', 'must be specified'] }
    $errors->keys;     # ['age', 'name']

=head2 messages

Returns a hash of error messages.

    $errros->add('name', 'can not be empty');
    $errors->messages; # { name => ['can not be empty'] }

=head2 set

Set messages for the given attribute. Messages must be an array referece.

    $errors->get('name'); # undef
    $errors->set('name', ['can not be empty']);
    $errors->get('name'); # ['can not be empty']

=head2 size

Returns the number of error messages.

    $errors->add('name', 'can not be empty');
    $errors->size # 1
    $errors->add('age', 'is invalid');
    $errors->size # 2

=head2 to_array

Alias for L<"full_messages">.

=head2 to_hash

Returns a hash of error messages. It will contain full messages if argument 1 is passed.

    $errors->messages;    # { name => ['can not be empty'] }
    $errors->messages(1); # { name => ['Name can not be empty'] }

=head2 values

Returns all message values.

    $errors->messages; # { age => ['is invalid'], name => ['can not be empty', 'must be specified'] }
    $errors->values;   # [['is invalid'], ['can not be empty', 'must be specified']]

=head1 LICENSE

Copyright (C) nkwhr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

nkwhr E<lt>naoya.kawahara[at]gmail.comE<gt>

=cut
