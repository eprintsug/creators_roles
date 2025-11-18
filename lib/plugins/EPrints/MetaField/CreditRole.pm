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

use strict;
use warnings;

use JSON;
use EPrints::MetaField::Id;

BEGIN
{
	our( @ISA );
	@ISA = qw( EPrints::MetaField::Longtext );
}


sub allow_edit
{
    my( $self, $session ) = @_;
    return $session->current_user->has_role( "credit_role:edit" ) ;
}

sub get_search_group { return 'credit_role'; }

sub get_property_defaults
{
	my( $self ) = @_;
	my %defaults = $self->SUPER::get_property_defaults;
	$defaults{input_rows} = $EPrints::MetaField::FROM_CONFIG;
	$defaults{maxlength} = 65535;
	$defaults{sql_index} = 0;
	$defaults{multiple} = 0;
	return %defaults;
}

sub cr_json_to_hash
{
	my ($self, $value) = @_;
    return( undef ) if !defined $value;
	return JSON::decode_json($value);   
}

sub cr_hash_to_json
{
	my ($self, $value) = @_;
	return( undef ) if !defined $value;
	my $json = JSON::encode_json($value);
	return( $json );
}


sub value_from_sql_row
{
	my( $self, $session, $row ) = @_;
	my $value = $self->SUPER::value_from_sql_row( $session, $row );
    return $self->cr_json_to_hash($value);
}

sub sql_row_from_value
{
	my( $self, $session, $value ) = @_;

	return( undef ) if !defined $value;
	
	$value =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]/\x{fffd}/g;
	
	$value =~ s/^\s+//;
	$value =~ s/\s+$//;

	return $self->cr_hash_to_json($value);
}

# Turns a JSON structure into a string then sorts the chars into order so it can be compared
sub _make_comparable
{
	my ($json) = @_;
	my @chars = split //, $json;
    @chars = sort @chars;
	return join '', @chars;
}

# Override DataObj's equal method as it does not work on our datatype
sub equals
{
	my( $a, $b ) = @_;

	# both undef is equal
	if( !EPrints::Utils::is_set($a) && !EPrints::Utils::is_set($b) )
	{
		return 1;
	}

	# one xor other undef is not equal
	if( !EPrints::Utils::is_set($a) || !EPrints::Utils::is_set($b) )
	{
		return 0;
	}

	my $ca = _make_comparable($a);
	my $cb = _make_comparable($b);

	return $ca eq $cb;
}

sub form_value_basic
{
	my( $self, $session, $basename, $object ) = @_;
	my $value = $self->SUPER::form_value_basic( $session, $basename, $object );

	return undef if( !EPrints::Utils::is_set( $value ) );
    
	return $self->cr_json_to_hash($value);
}

sub from_search_form
{
	my( $self, $session, $basename ) = @_;

	my $value = scalar($session->param( $basename ));
	my $match = "IN";
	my $merge = scalar($session->param( $basename."_merge" ));
	return( $value, $match, $merge );
}	

sub get_index_codes
{
	my( $self, $session, $value ) = @_;

	return( [], [], [] ) unless( EPrints::Utils::is_set( $value ) );

    $value = ref $value eq "ARRAY" ? @{$value}[0] : $value;
	$value = ref $value eq "HASH" ? $value : $self->cr_json_to_hash($value);
	
	my( $codes, $grepcodes, $ignored ) = $self->get_index_codes_basic( $session, $value );
	return( $codes, $grepcodes, $ignored );
}

sub get_index_codes_basic
{
	my( $self, $session, $value ) = @_;

	return( [], [], [] ) if !EPrints::Utils::is_set( $value );
	
	my %roles = %{$value};
	return( [], [], [] ) if scalar keys %roles == 0;

	my @values = ();
	
	foreach my $role (keys %roles) 
    {
		my @sizes = split "", $roles{$role};
		foreach my $size (@sizes)
		{
			push @values, "$role:$size";
		}
	}
	return( \@values, [], [] );
}

sub get_search_conditions
{   my( $self, $session, $dataset, $search_value, $match, $merge,
		$search_mode ) = @_;	

    my( $codes, $grepcodes, $ignored  ) = $self->get_index_codes($session, $self->cr_json_to_hash($search_value));

    my @conditions = ();

	foreach my $code (@{$codes})
	{
		# skip non sized role if a size has been specified
		next if $code =~ /\_$/ && scalar(@{$codes}) > 1;
	
		push @conditions,  EPrints::Search::Condition->new( 
	 		'index', 
	 		$dataset, 
	 		$self, 
	 		$code );
	}

    if ($merge eq "ANY") 
	{
		return EPrints::Search::Condition::Or->new(
        	@conditions
    	);
	}
	else 
	{
		return EPrints::Search::Condition::And->new(
        	@conditions
    	);
	}
}

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
	return get_display_value(undef, $session, $value, 0);
}

sub get_display_value
{
	my ($self, $session, $value, $show_first_only) = @_;
	
    my $html = $session->make_doc_fragment();
    return $html unless defined $value;

    my %roles = %{$value};
	return $html if scalar keys %roles == 0;
	
    foreach my $role (keys %roles) 
    {
		if (defined $self)
		{
            $html->appendChild($self->get_display_value_row($session, $role, $roles{$role}));
		}
		else
		{			
			$html->appendChild(get_display_value_row(undef, $session, $role, $roles{$role}));
		}
		if ($show_first_only)
		{
			my $numleft = (scalar keys %roles) - 1;
			$html->appendChild($session->make_text(" + $numleft")) if $numleft > 0;
			last;
		}
		else
		{
			$html->appendChild($session->html_phrase("lib/metafield:join_CreditRole"));
		}
    }
    # Remove the last ', ' separator
    $html->removeChild($html->lastChild) unless $show_first_only;
	return $html;
}

sub get_display_value_row
{
    my ($self, $session, $role, $size) = @_;
    my $html = $session->make_doc_fragment();
    $html->appendChild($session->html_phrase("credit_rolename_".$role));
    unless ($size eq "_")
    {
		my @size_display = ();
		my @sizes = split "", $size;
		foreach my $size (@sizes)
		{
			push @size_display, $session->phrase("credit_size_typename_".$size) unless $size eq "_";
		}		
		if (scalar @size_display > 0)
		{
			$html->appendChild($session->make_text(" ("));
			$html->appendChild($session->make_text(join(",", @size_display)));	
			$html->appendChild($session->make_text(")"));
		}
    }
   return $html;
}

sub render_single_value
{
    # TODO Link to ISO Credit pages?
	my( $self, $session, $value, $alllangs, $nolink, $object ) = @_;
	return $self->get_display_value($session, $value);
}

sub get_max_input_size
{
	my( $self ) = @_;

	return 65535;
}


sub get_input_col_titles
{
	my( $self, $session, $staff ) = @_;
	my @r  = ();
    return $self->SUPER::get_input_col_titles($session, $staff);
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
    # The hidden field contains the actual value for storage
	$input = $session->render_hidden_field($basename, $self->cr_hash_to_json($value));

    $html->appendChild($self->get_display_span($session, $basename, join(' ',@classes), $value));
    $html->appendChild($self->get_openclose_options_buttons($session, $basename));
    $html->appendChild($input);

	return [ [ { el=>$html } ] ];
}

# Shows a label on screen with human readable versions of selections
sub get_display_span
{
    my ($self, $session, $basename, $classes, $value) = @_;
    my $html = $session->make_doc_fragment();
	$classes .= " creators_credit_roles_display";
	my $div = $session->make_element("div", id => $basename."_display", name => $basename."_display", class=> $classes);
	$html->appendChild($div);
	$div->appendChild($session->make_text($self->get_display_value($session, $value, 1))); 
    return $html;
}

sub get_openclose_options_buttons
{
    my ($self, $session, $basename) = @_;
    my $html = $session->make_doc_fragment();

    my $ocbtn = $session->make_element("button", 
        "type" =>"button",
        "id" => $basename."_optsbtn_toggle",
        "onclick" => "credit_options_toggle(this); return false;",
        "class" => "ep_form_internal_button",
        "aria-expanded" => "false"
    );
    $ocbtn->appendChild($session->html_phrase("credit_optsbtn_open"));
    $html->appendChild($ocbtn) if $self->allow_edit($session);
    return $html;
}

sub render_search_input
{
	my( $self, $session, $searchfield, %opts ) = @_;
	my $frag = $session->make_doc_fragment;

	# complex text types
	my @text_tags = ( "ALL", "ANY" );
	my %text_labels = ( 
		"ANY" => $session->phrase( "lib/searchfield:text_any" ),
		"ALL" => $session->phrase( "lib/searchfield:text_all" ) );
	my $labelledby = ( $searchfield->get_form_prefix =~ m/^(c[0-9]+)?q[0-9]*$/ ) ? "Search" : $searchfield->get_form_prefix . "_label";
	if ( $searchfield->get_form_prefix =~ m/^(c[0-9]+)q[0-9]*$/ )
	{
		$labelledby = "_internal_" . $1 . "_search";
	}
	
	$frag->appendChild( 
		$session->render_option_list(
			name=>$searchfield->get_form_prefix."_merge",
			values=>\@text_tags,
			default=>$searchfield->get_merge,
			labels=>\%text_labels,
			#LGH swapped out for label 'aria-labelledby' => $labelledby,
			'aria-label' => "Search scope" ) );
	$frag->appendChild( $session->make_text(" ") );

	my @classes = (
		"ep_form_text ep_form_creditrole",
	); 

	# my $ariadescribedby = $self->get_describedby( $basename, $one_field_component );
	# $props{'aria-describedby'} = $ariadescribedby if $ariadescribedby ne "";
    # The hidden field contains the actual value for storage

	my $value = $searchfield->get_value();
	# $self->cr_hash_to_json($value)
    $frag->appendChild($self->get_display_span($session, $searchfield->get_form_prefix, join(' ',@classes), $self->cr_json_to_hash($value)));
    $frag->appendChild($session->render_hidden_field($searchfield->get_form_prefix, $value));

    my $optspanel = $session->make_element("div", 
                          "id"=>$searchfield->get_form_prefix."_optspanel", 
						  "class"=>"credit_options", 
						  "aria-role"=>"listbox");
	
    $frag->appendChild($optspanel);
#     $frag->appendChild($session->make_javascript( <<EOJ ));
# cr_display_search();
# EOJ
	return $frag;
}

sub render_search_description
{
	my( $self, $session, $sfname, $value, $merge, $match ) = @_;

	my( $phraseid );
	if( $match eq "EQ" || $match eq "EX" )
	{
		$phraseid = "lib/searchfield:desc_is";
	}
	elsif( $merge eq "ANY" ) # match = "IN"
	{
		$phraseid = "lib/searchfield:desc_any_in";
	}
	else
	{
		$phraseid = "lib/searchfield:desc_all_in";
	}

	my $valuedesc = $session->make_text( '"'.$self->get_display_value($session, $self->cr_json_to_hash($value)).'"' );
	
	return $session->html_phrase(
		$phraseid,
		name => $sfname, 
		value => $valuedesc );
}

sub to_sax
{
	my( $self, $value, %opts ) = @_;

	# MetaField::Compound relies on testing this specific attribute
	return if defined $self->{parent_name};

	return if !$opts{show_empty} && !EPrints::Utils::is_set( $value );

    my %roles = %{$value};

	my $handler = $opts{Handler};
	my $name = $self->name;

	$handler->start_element( {
		Prefix => '',
		LocalName => $name,
		Name => $name,
		NamespaceURI => EPrints::Const::EP_NS_DATA,
		Attributes => {},
	});

	foreach my $role (keys %roles)
	{
        $handler->start_element( {
			Prefix => '',
			LocalName => "item",
			Name => "item",
			NamespaceURI => EPrints::Const::EP_NS_DATA,
			Attributes => {},
		});

		$handler->start_element( {
			Prefix => '',
			LocalName => "role",
			Name => "role",
			NamespaceURI => EPrints::Const::EP_NS_DATA,
			Attributes => {},
		});

		$self->to_sax_basic( $role, %opts );
		$handler->end_element( {
			Prefix => '',
			LocalName => "role",
			Name => "role",
			NamespaceURI => EPrints::Const::EP_NS_DATA,
		});

		if ($roles{$role} ne "_")
		{
			$handler->start_element( {
				Prefix => '',
				LocalName => "size",
				Name => "size",
				NamespaceURI => EPrints::Const::EP_NS_DATA,
				Attributes => {},
			});

			$self->to_sax_basic( $roles{$role}, %opts );
			$handler->end_element( {
				Prefix => '',
				LocalName => "size",
				Name => "size",
				NamespaceURI => EPrints::Const::EP_NS_DATA,
			});
		}

        $handler->end_element( {
			Prefix => '',
			LocalName => "item",
			Name => "item",
			NamespaceURI => EPrints::Const::EP_NS_DATA,
		});
	}

	$handler->end_element( {
		Prefix => '',
		LocalName => $name,
		Name => $name,
		NamespaceURI => EPrints::Const::EP_NS_DATA,
	});
}

sub to_sax_basic
{
	my( $self, $value, %opts ) = @_;

	$opts{Handler}->characters( { Data => $value } );
}

# override Multipart
sub get_xml_schema_type
{
	my ($self) = @_;

	return $self->{type};
}

sub render_xml_schema_type
{
	my( $self, $session ) = @_;

	my $type = $session->make_element( "xs:complexType", name => $self->get_xml_schema_type );

	my $all = $session->make_element( "xs:all" );
	$type->appendChild( $all );
	my @fields = ("role", "size");
	foreach my $field (@fields)
	{
		my $element = $session->make_element( "xs:element", name => $field, minOccurs => 0 );
		$all->appendChild( $element );

		my $simpleType = $session->make_element( "xs:simpleType" );
		$element->appendChild( $simpleType );

		my $restriction = $session->make_element( "xs:restriction", base => "xs:string" );
		$simpleType->appendChild( $restriction );

		my $maxLength = $session->make_element( "xs:maxLength", value => 50 );
		$restriction->appendChild( $maxLength );
	}

	return $type;
}

# ######################################################################

sub start_element
{
	my( $self, $data, $epdata, $state ) = @_;

	++$state->{depth};

    if( $data->{LocalName} eq "item" )
	{
		$state->{in_value} = 1;
	}
	elsif( $data->{LocalName} eq "role" )
	{
		$state->{cr_in_role} = 1;
	}
	elsif( $data->{LocalName} eq "size" )
	{
		$state->{cr_in_size} = 1;
	}
}

sub end_element
{
	my( $self, $data, $epdata, $state ) = @_;

	if( $data->{LocalName} eq "item" )
	{
		$state->{in_value} = 0;
	}
	elsif( $data->{LocalName} eq "role" )
	{
		$state->{cr_in_role} = 0;
	}
	elsif( $data->{LocalName} eq "size" )
	{
		$state->{cr_in_size} = 0;
	}
	--$state->{depth};
}

sub characters
{
	my( $self, $data, $epdata, $state ) = @_;
	# In cr = have key, in size = have value
	
    my %value = defined $epdata->{$self->name}[0] ? %{$epdata->{$self->name}[0]}: ();
    if( $state->{cr_in_role} )
	{
		$value{ $data->{Data} } = "_";
		$state->{current_role} = $data->{Data};
	}
	elsif( $state->{cr_in_size} )
	{
		$value{ $state->{current_role} } = $data->{Data};
	}
	$epdata->{$self->name}[0] = \%value; 
}


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

