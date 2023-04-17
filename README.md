# Creator Roles for EPrints
Adding roles to an EPrints repository using the [CRediT](https://www.casrai.org/credit.html) taxonomy.
The initial commit is code that's been used for testing at University of Glasgow which stores the roles in a new compound field 'creators_roles' and provides associated phrases, workflow and render.

=========

**Liam's version with CRediT drop down:**

This is an experimental version of the CRediT plugin with a custom javascript control.

To install:
Add this to the compound field for creators:

```
{
      sub_name => 'credit_roles',
      type => 'CreditRole',
			input_cols => 1,
			allow_null => 1,
			input_cols => 25
}
```

Important! Regenerate your static files to include the javascript needed for the custom control:
```
$ bin/generate_abstracts [your repository name]
```

To include the CRediT roles in the abstract add something like this to cfg/citations/eprint/summary_page.xml:
```

    <epc:foreach expr="$item.property('creators')" iterator="creator">
      <epc:if test="is_set($creator{orcid})">
        <tr class="ep_row">
          <th align="right"><epc:print expr="$creator{name}.property('family')" />, <epc:print expr="$creator{name}.property('given')" />:</th>
          <td valign="top">
            <a href="https://orcid.org/{$creator{orcid}}"><img id="orcid_logo" src="/images/orcid_16x16.png" alt="ORCiD logo" />https://orcid.org/<epc:print expr="$creator{orcid}" /></a>  
            <epc:print expr="$creator.render_value_function('EPrints::MetaField::CreditRole::render_value_function', 'credit_roles', $creator{credit_roles})" />
          </td>
        </tr>
      </epc:if>
    </epc:foreach>
```

This plugin was made for EPrints 3.3 so may need adapting to work on EPrints 3.4. It should also be considered as alpha quality until it is tested some more!



