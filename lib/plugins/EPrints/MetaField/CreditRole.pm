######################################################################
#
# EPrints::MetaField::CreditRole;
#
######################################################################
#
#
######################################################################

=pod

=head1 NAME

B<EPrints::MetaField::CreditRole> - CRedIT taxonomy role

=head1 DESCRIPTION

not done

=over 4

=cut

package EPrints::MetaField::CreditRole;

use EPrints::MetaField::Id;

@ISA = qw( EPrints::MetaField::Id );

use strict;

sub get_search_group { return 'credit_role'; }

sub render_value
{
	my( $self, $session, $value, $alllangs, $nolink, $object ) = @_;

	if( defined $self->{render_value} )
	{
		return $self->call_property( "render_value", 
			$session, 
			$self, 
			$value, 
			$alllangs, 
			$nolink,
			$object );
	}
	return $self->render_single_value( $session, $value, $alllangs, $nolink, $object );
}

# Static version for use in render XML 
# EPrints::MetaField::CreditRole::render_value_function
sub render_value_function
{
    my ($session, $field, $value) = @_; 

    my $html = $session->make_doc_fragment();
    return $html unless defined $value;
    my @roles = split(" ", $value);
    foreach my $role (@roles) 
    {
        $html->appendChild(get_human_readable(undef,$session, $role));
        $html->appendChild($session->html_phrase("lib/metafield:join_CreditRole"));
    }
    # Remove the last ', ' separator
    $html->removeChild($html->lastChild);
	return $html;
}

sub get_human_readable
{
    my ($self, $session, $role) = @_;
    my $html = $session->make_doc_fragment();
    my $role_name = undef;
    my $role_size = undef;
    if ($role =~ /(.*)\-([a-z]{1,2})/)
    {
        $role_name = $1;
        $role_size = $2;
    }
    else
    {
        # No size
        $role_name = $role;        
    }
    $html->appendChild($session->html_phrase("credit_rolename_".$role_name));
    if ($role_size)
    {
        $html->appendChild($session->make_text(" ("));
        $html->appendChild($session->html_phrase("credit_size_typename_".$role_size));
        $html->appendChild($session->make_text(")"));
    }
   return $html;
}

sub render_single_value
{
    # TODO Link to ISO Credit pages?
	my( $self, $session, $value, $alllangs, $nolink, $object ) = @_;
    my $html = $session->make_doc_fragment();
    # Check if empty
    return $html unless defined $value;
    $value =~ s/^\s+|\s+$//g;
    return $html if $value eq "";

    my @roles = split " ", $value;
    foreach my $role (@roles) 
    {
        $html->appendChild($self->get_human_readable($session, $role));
        $html->appendChild($session->html_phrase("lib/metafield:join_CreditRole"));
    }
    # Remove the last ', ' separator
    $html->removeChild($html->lastChild);
	return $html;
}

# TODO VALIDATE

sub get_max_input_size
{
	my( $self ) = @_;

	return 500;
}

sub get_basic_input_elements
{
	my( $self, $session, $value, $basename, $staff, $obj, $one_field_component  ) = @_;

	my $maxlength = $self->get_max_input_size;
	my $size = ( $maxlength > $self->{input_cols} ?
					$self->{input_cols} : 
					$maxlength );

    my $html = $session->make_doc_fragment();
	my $input;

	if( defined $self->{render_input} )
	{
		$input = $self->call_property( "render_input",
			$self,
			$session, 
			$value, 
			$self->{dataset}, 
			$staff,
			undef,
			$obj,
			$basename,
			$one_field_component );
        return [ [ { el=>$html } ] ];
	}

	my @classes = (
		"ep_form_text ep_form_creditrole",
	);

	my $readonly = ( $self->{readonly} && $self->{readonly} eq "yes" ) ? 1 : undef;
	push @classes, "ep_readonly" if $readonly;


	if( defined($self->{dataset}) )
	{
		push @classes, join('_', 'ep', $self->{dataset}->base_id, $self->name);
		push @classes, join('_', 'eptype', $self->{dataset}->base_id, $self->type);
	}

	# my $ariadescribedby = $self->get_describedby( $basename, $one_field_component );
	# $props{'aria-describedby'} = $ariadescribedby if $ariadescribedby ne "";
	$input = $session->render_hidden_field($basename, $value);

    $html->appendChild($self->get_display_span($session, $basename, join(' ',@classes), $value));
    $html->appendChild($self->get_openclose_options_buttons($session, $basename));
    $html->appendChild($input);

	return [ [ { el=>$html } ] ];
}

sub get_display_span
{
    my ($self, $session, $basename, $classes, $value) = @_;
    my %props = (
		class=> $classes,
		name => $basename."_display",
        id => $basename."_display",
        value => $self->render_single_value( $session, $value, undef, undef, undef ),
        size => $self->{input_cols},
        readonly => "readonly",
        maxlength => $self->get_max_input_size,
        'aria-labelledby' => $self->get_labelledby( $basename ),
	);
    return $session->render_input_field(%props);
}

sub get_openclose_options_buttons
{
    my ($self, $session, $basename) = @_;
    my $html = $session->make_doc_fragment();

    my $ocbtn = $session->make_element("button", 
        "type" =>"button",
        "id" => $basename."_optsbtn_open",
        "onclick" => "credit_options_open(this); return false;",
        "class" => "ep_form_internal_button"
    );
    $ocbtn->appendChild($session->html_phrase("credit_optsbtn_open"));
    $html->appendChild($ocbtn);

    my $ccbtn = $session->make_element("button", 
        "type" =>"button",
        "id" => $basename."_optsbtn_close",
        "onclick" => "credit_options_close(this); return false;",
        "class" => "ep_form_internal_button cr-hidden",
    );
    $ccbtn->appendChild($session->html_phrase("credit_optsbtn_close"));
    $html->appendChild($ccbtn);
    return $html;
}


######################################################################
1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2023 University of Kent
=for COPYRIGHT END

=for LICENSE BEGIN

This file is a custom add on to EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

