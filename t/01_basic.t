use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok 'ActiveModelLike::Errors';
}

subtest '#new' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    isa_ok $errors->{messages}, 'HASH';
};

subtest '#messages' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->messages, $errors->{messages};
};

subtest '#clear' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->{messages} = { name => ['can not be empty'] };
    is keys %{$errors->messages}, 1;
    $errors->clear;
    is keys %{$errors->messages}, 0;
};

subtest '#include' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->{messages} = { name => ['can not be empty'] };
    is $errors->include('name'), 1;
    is $errors->include('age'), 0;
};

subtest '#has_key' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->has_key('name'), $errors->include('name');
};

subtest '#key' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->key('name'), $errors->include('name');
};

subtest '#get' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->{messages} = { name => ['can not be empty'] };
    is_deeply $errors->get('name'), ['can not be empty'];
    is $errors->get('age'), undef;
};

subtest '#set' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->get('name'), undef;
    $errors->set(name => ['can not be empty']);
    is_deeply $errors->get('name'), ['can not be empty'];
};

subtest '#delete' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->set(name => ['can not be empty']);
    is_deeply $errors->get('name'), ['can not be empty'];
    is_deeply $errors->delete('name'), ['can not be empty'];
    is $errors->get('name'), undef;
};

subtest '#each' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->set(name => ['can not be empty', 'must be specified']);
    $errors->set(age => ['can not be empty', 'must be specified']);

    my $COUNT = { name => 0, age => 0 };

    $errors->each(sub {
        my ($attribute, $message) = @_;
        $COUNT->{$attribute}++;
    });

    is $COUNT->{name}, 2;
    is $COUNT->{age}, 2;

    subtest 'when argument is not subroutine reference' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        eval { $errors->each('foo') };
        like $@, qr/^Argument must be a subroutine reference/;
    };
};

subtest '#size' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->set(name => ['can not be empty', 'must be specified']);
    $errors->set(age => ['can not be empty', 'must be specified']);
    is $errors->size, 4
};

subtest '#count' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->count, $errors->size;
};

subtest '#values' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->set(name => ['can not be empty', 'must be specified']);
    $errors->set(age => ['can not be empty', 'must be specified']);
    is_deeply $errors->values, [
        ['can not be empty', 'must be specified'],
        ['can not be empty', 'must be specified']
    ];
};

subtest '#keys' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->set(name => ['can not be empty']);
    $errors->set(age => ['can not be empty']);
    is_deeply $errors->keys, ['age', 'name'];
};

subtest '#is_empty' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->is_empty, 1;
    $errors->set(name => ['can not be empty']);
    is $errors->is_empty, 0;
};

subtest '#is_blank' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->is_blank, $errors->is_empty;
};

subtest '#to_hash' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->add(name => 'is invalid');
    $errors->add(name => 'must be implemented');
    is_deeply $errors->to_hash, {
        name => ['is invalid', 'must be implemented']
    };
    is_deeply $errors->to_hash(1), {
        name => ['Name is invalid', 'Name must be implemented']
    };
};

subtest '#add' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is_deeply $errors->add('name'), ['is invalid'];
    is_deeply $errors->add(name => 'must be implemented'), ['is invalid', 'must be implemented'];
    is_deeply $errors->messages, { name => ['is invalid', 'must be implemented'] };

    subtest 'when strict mode => 1' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        eval { $errors->add(name => undef, { strict => 1 }) };
        like $@, qr/^Strict validation failed/;
    };

    subtest 'when strict mode with custom exception' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        eval { $errors->add(name => undef, { strict => 'Name missing error' }) };
        like $@, qr/^Name missing error/;
    };

    subtest 'when adding undef as a message' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        is_deeply $errors->add(name => undef), ['is invalid'];
    };

    subtest 'when adding empty string as a message' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        is_deeply $errors->add(name => ''), ['is invalid'];
    };

    subtest 'when message is a subroutine reference' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        $errors->add(name => sub { return 'foobar'; });
        is_deeply $errors->messages, { name => ['foobar'] };
    };
};

subtest '#is_added' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->add(name => 'is invalid');

    is $errors->is_added(name => 'is invalid'), 1;
    is $errors->is_added(name => 'must be implemented'), 0;

    subtest 'when a message is not passed' => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        is $errors->is_added('name'), 0;
        $errors->add('name');
        is $errors->is_added('name'), 1;
    };
};

subtest '#full_messages' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->add(name => 'is invalid');
    $errors->add(name => 'must be implemented');
    $errors->add(age => 'is invalid');
    is_deeply $errors->full_messages, [
        'Age is invalid',
        'Name is invalid',
        'Name must be implemented'
    ];
};

subtest '#to_array' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is_deeply $errors->to_array, $errors->full_messages;
};

subtest '#full_messages_for' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    $errors->add(name => 'is invalid');
    $errors->add(name => 'must be implemented');
    is_deeply $errors->full_messages_for('name'), [
        'Name is invalid',
        'Name must be implemented'
    ];
    is_deeply $errors->full_messages_for('age'), [];
};

subtest '#full_message' => sub {
    my $errors = new_ok 'ActiveModelLike::Errors';
    is $errors->full_message('method.function' => 'is invalid'), 'Method function is invalid';

    subtest "when attribute is 'base'" => sub {
        my $errors = new_ok 'ActiveModelLike::Errors';
        is $errors->full_message(base => 'is invalid'), 'is invalid';
    };
};

done_testing;
