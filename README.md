# NAME

ActiveModelLike::Errors - A Perl port of ActiveModel::Errors

# SYNOPSIS

    use ActiveModelLike::Errors;

    my $errors = ActiveModelLike::Errors->new;

    $errros->add('age', 'is invalid');
    $errros->add('name', 'can not be empty');

    $errors->is_empty;      # 0
    $errors->messages;      # { age => ['is invalid'], name => ['can not be empty'] }
    $errors->full_messages; # ['Age is invalid', 'Name can not be empty']

# DESCRIPTION

This is a port of Rails' ActiveModel::Errors to Perl, which provides a modified Hash that you can include in your object for handling error messages.

Due to lack of other related modules (e.g. ActiveModel::Validations, ActiveModel::Translation and etc.), it is not fully comaptible with the original, but may be useful in some cases if you are familiar with its interface.

# METHODS

## add

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

## clear

Clear the error messages.

    $errors->full_messages; # ['Name is invalid']
    $errors->clear;
    $errors->full_messages; # {}

## count

Alias for ["size"](#size).

## delete

Delete messages for the attribute. Returns the deleted messages.

    $errors->get('name');    # ['']
    $errors->delete('name'); # ['is invalid']
    $errors->get('name');    # undef

## each

Iterates through each attribute/message pair in the error messages hash.

    $errors->add('name', 'can not be empty');
    $errors->add('name', 'is invalid');

    $errors->each(sub {
        my ($attribute, $message) = @_;
        # do_something
    });

## full\_message

Returns a full message for a given attribute.

    $errors->full_message('name', 'is invalid'); # 'Name is invalid'

## full\_messages

Returns all the full error messages in an array.

    $errors->add('age', 'can not be empty');
    $errors->add('name', 'is invalid');
    $errors->add('name', 'can not be empty');
    $errors->full_messages; # ['Age can not be empty', 'Name is invalid', 'Name can not be empty']

## full\_messages\_for

Returns all the full error messages for a given attribute.

    $errors->add('name', 'is invalid');
    $errors->add('name', 'can not be empty');
    $errors->full_messages_for('name'); # ['Name is invalid', 'Name can not be empty']
    $errors->full_messages_for('age');  # []

## get

Get messages for the given attribute.

    $errors->messages;    # { name => ['is invalid'] }
    $errors->get('name'); # ['is invalid']
    $errors->get('age');  # undef

## has\_key

Alias for ["include"](#include).

## include

Returns "1" if the error messages include an error for the given attribute.
Otherwise returns "0".

    $errors->messages;        # { name => ['is invalid'] }
    $errors->include('name'); # 1
    $errors->include('age');  # 0

## is\_added

Returns "1" if an error on the attribute with the given message is present.
Otherwise returns "0".

    $errors->add('name', 'is invalid');
    $errors->is_added('name', 'is invalid');       # 1
    $errors->is_added('name', 'can not be empty'); # 0

## is\_blank

Alias for ["is\_empty"](#is_empty).

## is\_empty

Returns "1" if no errors are found. Otherwise returns "0".

    $errors->messages; # { name => 'can not be empty' }
    $errors->is_empty; # 0
    $errors->clear;
    $errors->is_empty: # 1

## key

Alias for ["include"](#include).

## keys

Returns all message attributes.

    $errors->messages; # { age => ['is invalid'], name => ['can not be empty', 'must be specified'] }
    $errors->keys;     # ['age', 'name']

## messages

Returns a hash of error messages.

    $errros->add('name', 'can not be empty');
    $errors->messages; # { name => ['can not be empty'] }

## set

Set messages for the given attribute. Messages must be an array referece.

    $errors->get('name'); # undef
    $errors->set('name', ['can not be empty']);
    $errors->get('name'); # ['can not be empty']

## size

Returns the number of error messages.

    $errors->add('name', 'can not be empty');
    $errors->size # 1
    $errors->add('age', 'is invalid');
    $errors->size # 2

## to\_array

Alias for ["full\_messages"](#full_messages).

## to\_hash

Returns a hash of error messages. It will contain full messages if argument 1 is passed.

    $errors->messages;    # { name => ['can not be empty'] }
    $errors->messages(1); # { name => ['Name can not be empty'] }

## values

Returns all message values.

    $errors->messages; # { age => ['is invalid'], name => ['can not be empty', 'must be specified'] }
    $errors->values;   # [['is invalid'], ['can not be empty', 'must be specified']]

# LICENSE

Copyright (C) nkwhr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

nkwhr <naoya.kawahara\[at\]gmail.com>
