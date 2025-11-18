# Creator Roles for EPrints
Adding creator roles to an EPrints repository using the [CRediT](https://www.casrai.org/credit.html) taxonomy.  

## EPServices Fork

The `eprintug` plugin [creators_roles](https://github.com/eprintsug/creators_roles) has been forked by EPServices to translate into an ingredient format and structure.

### Versions & Compatability

| EPrints Version | creators_roles Release Version | Tested | Released | Date |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| 3.5 | v1.0.0-35 | ❌ | ❌ | Future |
| 3.4.5 | v1.0.0-34 | ❌ | ❌ | Future |
| [3.4.5](https://github.com/eprints/eprints3.4/releases/tag/v3.4.5) | [Initial Fork v0.0.1-alpha](https://github.com/eprints/creators_roles/releases/tag/v0.0.1-alpha) | ✅ | N/A | 27/01/24 |

### Improvements & Issues

#### Current EPrints Versions (>3.4.5) 1.0.0 Release

- [#1 Local admins should be able to view this as standard](https://github.com/eprints/creators_roles/issues/1)
- [#3 Role subfield is removed if the user doesn't have the permissions associated with the field credit_role:edit](https://github.com/eprints/creators_roles/issues/3)
- [#5 Improve styling in workflow](https://github.com/eprints/creators_roles/issues/5)
- [#6 Can you and should you be able to search over this sub field?](https://github.com/eprints/creators_roles/issues/6)
- [#7 Test accessibility before 1.0.0 release](https://github.com/eprints/creators_roles/issues/7)
- [#11 Clean up code base](https://github.com/eprints/creators_roles/issues/11)

#### Future EPrints Versions

- [#8 Update to work with future eprints versions (backwards compatible)](https://github.com/eprints/creators_roles/issues/8)
- [#9 Update to use new JSON field](https://github.com/eprints/eprints3.5/issues/52) (relies on new feature in 3.5 [#52 JSON as a standard MetaField](https://github.com/eprints/eprints3.5/issues/52))
- [#10 Update README Instructions for 3.5 before 1.1.0 release](https://github.com/eprints/creators_roles/issues/10)

## Installation Instructions

> These instructions are valid for EPrints v3.4.5

1. Install the ingredient in the `/opt/eprints3/ingredients` directory.

	```bash
 	cd /opt/eprints3/ingredients/
	git clone https://github.com/eprints/creators_roles.git
 	```

2. Enable to ingredient in the relevant flavour `inc` file

	> example shown for publications flavour `pub_lib`.

	**Edit** this file `/opt/eprints3/flavours/pub_lib/inc`

 	**Add** this line
	```bash
	ingredients/creators_roles
	```

3. Add this to the compound field for creators:

	```perl
	{
		sub_name => 'credit_roles',
		type => 'CreditRole',
		input_cols => 1,
		allow_null => 1,
		input_cols => 25
	}
	```

4. Regenerate your static files to include the javascript needed for the custom control:

	```bash
	$ bin/generate_static [your repository name]
	```

5. Enable editing of the credit role by adding `credit_role:edit` to the appropriate role in user_roles.pl or adding as a user permission.

## Developer Credits

### Developers / Creators:

[Micheal Eadie](https://github.com/MickEadie), University of Glasgow  
[Liam Green-Hughes](https://github.com/leg20-unikent), University of Kent  

### Developers:
[Edward Oakley](https://github.com/fatchild), EPrints Services
