# Admins and local admins should be able to edit the creator_role sub field 
push @{$c->{user_roles}->{admin}}, 'credit_role:edit' if defined $c->{user_roles}->{admin};
push @{$c->{user_roles}->{local_admin}}, 'creator-roles-edit' if defined $c->{user_roles}->{local_admin};

foreach my $f ( @{$c->{fields}->{eprint}} )
{
    if( $f->{name} eq "contributors" )
    {
        push @{$f->{fields}},
        {
            sub_name => 'credit_roles',
            type => 'CreditRole',
            input_cols => 1,
            allow_null => 1,
            input_cols => 25
        }
    }
}
