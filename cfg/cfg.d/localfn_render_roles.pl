# sub to render the roles without the id showing in the format, name: role1, role2, role3...

# I'm sure there's a more elegant way to do this! but it works for now

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}

$c->{localfn_render_roles} = sub {

  my( $session, $field, $value, $object) = @_;
  my $span = $session->make_element( "span" );
	my %roles;
	my @ids;
	my @unique_ids;

	for( my $i=0; $i<scalar @{$value}; ++$i )
	{
	   my $row = $value->[$i];
		 my $role = $row->{role};
		 my $role_phrase = $session->html_phrase("credit_typename_$role"); #better to have the phrase appear as the value
	   my $id = $row->{id};

     # puts the name value in the right format i.e. Jones, J.
		 my $given = $row->{name}->{given}||" ";
			  $given =~ s/\b(\w)\w*/$1\./g;
		    $given =~ s/\.\./\./g;
		    $given =~ s/(\, [A-Z]{1})(.*$)/$1./;
	   my $family = $row->{name}->{family}||" ";
		 my $name = $family . ", " . $given;

		 push( @{ $roles{$id . ":" . $name} }, $role_phrase ); # gives us a $roles hash with key/value id:name=>role

		 push (@ids, $id);
		 @unique_ids = uniq(@ids); # use this to get unique author ids to loop through below
   }

	 foreach my $uid (@unique_ids)
	 {
		 foreach my $k ( sort keys %roles ) # loop through the roles hash to find a key/id match
		 {
		     if ($k =~ /^$uid/)
			   {
				    my $roles_str = join(", ", @{ $roles{$k} } ); # put the roles in a string
				    my (undef, $just_name) = split(':\s*', $k); # we don't want to display the ID part, just the name
				    my $str = $session->make_text($just_name . ": " . $roles_str);
				    $span->appendChild( $str );
				    $span->appendChild( $session->make_element( 'br' ) );
			   }
		 }
	 }
	 return $span;
};
