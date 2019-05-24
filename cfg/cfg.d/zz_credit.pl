# addition of extra role field to enable adding of 1-n roles

push @{$c->{fields}->{eprint}},
{

    name => "creators_roles",
    type => "compound",
    multiple => 1,
    show_in_html => 1,
    render_value => 'localfn_render_roles',
    fields => [
                  {
                    sub_name => 'name',
		                type => 'name',
		                hide_honourific => 1,
		                hide_lineage => 1,
		                family_first => 1,
                  },
                  {
                    sub_name => 'id',
                    type => 'text',
                    input_cols => 20,
                    export_as_xml => 0,
                  },
                  {
                    sub_name => 'role',
                    type => 'namedset',
                    set_name => 'credit',
                  }
                ],
    export_as_xml => 0,
    input_boxes => 2,
};
