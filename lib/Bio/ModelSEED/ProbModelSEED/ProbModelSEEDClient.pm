package Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient

=head1 DESCRIPTION


=head1 ProbModelSEED


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 list_gapfill_solutions

  $output = $obj->list_gapfill_solutions($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
list_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
gapfill_id is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a gapfill_id
	gapfill has a value which is a ref
	media has a value which is a ref
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a ref
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string

</pre>

=end html

=begin text

$input is a list_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
list_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
gapfill_id is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a gapfill_id
	gapfill has a value which is a ref
	media has a value which is a ref
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a ref
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string


=end text

=item Description



=back

=cut

sub list_gapfill_solutions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_gapfill_solutions (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_gapfill_solutions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_gapfill_solutions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_gapfill_solutions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_gapfill_solutions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_gapfill_solutions",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_gapfill_solutions',
				       );
    }
}



=head2 manage_gapfill_solutions

  $output = $obj->manage_gapfill_solutions($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a manage_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
manage_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
	selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int
ref is a string
gapfill_id is a string
gapfill_command is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a gapfill_id
	gapfill has a value which is a ref
	media has a value which is a ref
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a ref
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string

</pre>

=end html

=begin text

$input is a manage_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
manage_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
	selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int
ref is a string
gapfill_id is a string
gapfill_command is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a gapfill_id
	gapfill has a value which is a ref
	media has a value which is a ref
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a ref
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string


=end text

=item Description



=back

=cut

sub manage_gapfill_solutions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function manage_gapfill_solutions (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to manage_gapfill_solutions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'manage_gapfill_solutions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.manage_gapfill_solutions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'manage_gapfill_solutions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method manage_gapfill_solutions",
					    status_line => $self->{client}->status_line,
					    method_name => 'manage_gapfill_solutions',
				       );
    }
}



=head2 list_fba_studies

  $output = $obj->list_fba_studies($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
list_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a fba_id
	fba has a value which is a ref
	objective has a value which is a float
	media has a value which is a ref
	objective_function has a value which is a string
timestamp is a string

</pre>

=end html

=begin text

$input is a list_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
list_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a fba_id
	fba has a value which is a ref
	objective has a value which is a float
	media has a value which is a ref
	objective_function has a value which is a string
timestamp is a string


=end text

=item Description



=back

=cut

sub list_fba_studies
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_fba_studies (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_fba_studies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_fba_studies');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_fba_studies",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_fba_studies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_fba_studies",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_fba_studies',
				       );
    }
}



=head2 delete_fba_studies

  $output = $obj->delete_fba_studies($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a delete_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
delete_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
ref is a string
gapfill_id is a string
gapfill_command is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a fba_id
	fba has a value which is a ref
	objective has a value which is a float
	media has a value which is a ref
	objective_function has a value which is a string
timestamp is a string

</pre>

=end html

=begin text

$input is a delete_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
delete_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
ref is a string
gapfill_id is a string
gapfill_command is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is a fba_id
	fba has a value which is a ref
	objective has a value which is a float
	media has a value which is a ref
	objective_function has a value which is a string
timestamp is a string


=end text

=item Description



=back

=cut

sub delete_fba_studies
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_fba_studies (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_fba_studies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_fba_studies');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.delete_fba_studies",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'delete_fba_studies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_fba_studies",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_fba_studies',
				       );
    }
}



=head2 list_model_edits

  $output = $obj->list_model_edits($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
list_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
edit_id is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is an edit_id
	edit has a value which is a ref
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string

</pre>

=end html

=begin text

$input is a list_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
list_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
ref is a string
edit_id is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is an edit_id
	edit has a value which is a ref
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string


=end text

=item Description



=back

=cut

sub list_model_edits
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_model_edits (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_model_edits:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_model_edits');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_model_edits",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_model_edits',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_model_edits",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_model_edits',
				       );
    }
}



=head2 manage_model_edits

  $output = $obj->manage_model_edits($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a manage_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
manage_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
	new_edit has a value which is an edit_data
ref is a string
edit_id is a string
gapfill_command is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is an edit_id
	edit has a value which is a ref
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string

</pre>

=end html

=begin text

$input is a manage_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
manage_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a ref
	commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
	new_edit has a value which is an edit_data
ref is a string
edit_id is a string
gapfill_command is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a timestamp
	id has a value which is an edit_id
	edit has a value which is a ref
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string


=end text

=item Description



=back

=cut

sub manage_model_edits
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function manage_model_edits (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to manage_model_edits:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'manage_model_edits');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.manage_model_edits",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'manage_model_edits',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method manage_model_edits",
					    status_line => $self->{client}->status_line,
					    method_name => 'manage_model_edits',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ProbModelSEED.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'manage_model_edits',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method manage_model_edits",
            status_line => $self->{client}->status_line,
            method_name => 'manage_model_edits',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient\n";
    }
    if ($sMajor == 0) {
        warn "Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

********************************************************************************
    Universal simple type definitions
   	********************************************************************************


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ref

=over 4



=item Description

Reference to location in PATRIC workspace (e.g. /home/chenry/models/MyModel)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 timestamp

=over 4



=item Description

Standard perl timestamp (e.g. 2015-03-21-02:14:53)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_id

=over 4



=item Description

ID of gapfilling solution


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fba_id

=over 4



=item Description

ID of FBA study


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 edit_id

=over 4



=item Description

ID of model edits


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_command

=over 4



=item Description

An enum of commands to manage gapfilling solutions [D/I/U]; D = delete, I = integrate, U = unintegrate


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reaction_id

=over 4



=item Description

ID of reaction in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 compound_id

=over 4



=item Description

ID of compound in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Description

ID of feature in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 compartment_id

=over 4



=item Description

ID of compartment in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reaction_direction

=over 4



=item Description

An enum of directions for reactions [</=/>]; < = reverse, = = reversible, > = forward


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_reaction

=over 4



=item Description

********************************************************************************
    Complex data structures to support functions
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reaction has a value which is a ref
direction has a value which is a reaction_direction
compartment has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reaction has a value which is a ref
direction has a value which is a reaction_direction
compartment has a value which is a string


=end text

=back



=head2 gapfill_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is a gapfill_id
gapfill has a value which is a ref
media has a value which is a ref
integrated has a value which is a bool
integrated_solution has a value which is an int
solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is a gapfill_id
gapfill has a value which is a ref
media has a value which is a ref
integrated has a value which is a bool
integrated_solution has a value which is an int
solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction


=end text

=back



=head2 fba_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is a fba_id
fba has a value which is a ref
objective has a value which is a float
media has a value which is a ref
objective_function has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is a fba_id
fba has a value which is a ref
objective has a value which is a float
media has a value which is a ref
objective_function has a value which is a string


=end text

=back



=head2 edit_reaction

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a string
1: (coefficient) a float
2: (compartment) a string

gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
direction has a value which is a reaction_direction

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a string
1: (coefficient) a float
2: (compartment) a string

gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
direction has a value which is a reaction_direction


=end text

=back



=head2 edit_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is an edit_id
edit has a value which is a ref
reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
0: a float
1: a compartment_id


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a timestamp
id has a value which is an edit_id
edit has a value which is a ref
reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
0: a float
1: a compartment_id



=end text

=back



=head2 list_gapfill_solutions_params

=over 4



=item Description

********************************************************************************
    Functions for managing gapfilling studies
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref


=end text

=back



=head2 manage_gapfill_solutions_params

=over 4



=item Description

FUNCTION: manage_gapfill_solutions
DESCRIPTION: This function manages the gapfill solutions for a model and returns gapfill solution data

REQUIRED INPUTS:
ref model - reference to model to integrate solutions for
mapping<gapfill_id,gapfill_command> commands - commands to manage gapfill solutions

OPTIONAL INPUTS:
mapping<gapfill_id,int> selected_solutions - solutions to integrate


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int


=end text

=back



=head2 list_fba_studies_params

=over 4



=item Description

********************************************************************************
    Functions for managing FBA studies
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref


=end text

=back



=head2 delete_fba_studies_params

=over 4



=item Description

FUNCTION: delete_fba_studies
DESCRIPTION: This function deletes fba studies associated with model

REQUIRED INPUTS:
ref model - reference to model to integrate solutions for
list<fba_id> fbas - list of FBA studies to delete


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command


=end text

=back



=head2 list_model_edits_params

=over 4



=item Description

********************************************************************************
    Functions for editing models
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref


=end text

=back



=head2 manage_model_edits_params

=over 4



=item Description

FUNCTION: manage_model_edits
DESCRIPTION: This function manages edits to model submitted by user

REQUIRED INPUTS:
ref model - reference to model to integrate solutions for
mapping<edit_id,gapfill_command> commands - list of edit commands

OPTIONAL INPUTS:
edit_data new_edit - list of new edits to add


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
new_edit has a value which is an edit_data

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a ref
commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
new_edit has a value which is an edit_data


=end text

=back



=cut

package Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;