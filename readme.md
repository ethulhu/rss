Simple terminal RSS getter/reader
=================================

You will need

* postgres
* ruby, with gems
	* active_record
	* reverse_markdown
	* pg

Configuration
-------------

Config is defined in `~/.rssrc`, and is a json object that must have at least `"db"`, containing a hash with `adapter`,`host`,`user`,`password`, and `database`.
For example,

	{
		"db": {
			"adapter": "postgresql",
			"database": "rss",
			"host": "localhost",
			"password": "aligator7",
			"user": "rss"
		}
	}
