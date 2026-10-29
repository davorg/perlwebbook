# Repository findings

Examined on 2026-10-29, starting at commit `f007f3d` (2015-12-28).
These findings describe the checked-in sources and local verification results.
External websites and services were not checked.

## Purpose and state

**Perl Web Book**, by Dave Cross, is an unfinished book about developing web
applications with Perl. [about.md](about.md) explains the motivation: provide
teaching material that moves readers beyond older approaches to Perl web
development. [plan.md](plan.md) outlines the intended coverage.

The main deliverable is an ebook assembled from Markdown. Supporting code
includes Moose demonstrations and two separate Dancer2 applications. The
repository contains no website publishing pipeline, root application server,
or continuous integration configuration.

The latest commit at the start of this examination dates from December 2015.
The manuscript, dependency declarations, and conversion commands reflect that
period; successful operation with today's tools cannot be assumed.

## Repository map

| Path | Role |
| --- | --- |
| [chapters.txt](chapters.txt) | Ordered list of the 12 Markdown inputs included in the ebook. |
| [chapters/](chapters/) | Manuscript, including framework subsections. |
| [title.txt](title.txt) | Pandoc title block naming the book and author. |
| [metadata.xml](metadata.xml) | Intended EPUB metadata, including `en-GB`, publisher, publication date, and copyright. |
| [epub.css](epub.css) | Ebook typography and table of contents styling. |
| [Makefile](Makefile) | EPUB creation and conversions to MOBI and PDF. |
| [BUILD.md](BUILD.md) | Original tool installation and conversion instructions. |
| [converters.png](converters.png) | Build process illustration referenced by `BUILD.md`. |
| [code/moose/](code/moose/) | `Person` class and six demonstration scripts. |
| [code/dancer2/](code/dancer2/) | BookWeb reading-list application and MySQL initialization SQL. |
| [code/todo/](code/todo/) | ToDo application, MySQL schema, schema-loader configuration, and command-line utilities. |

`README.md`, `about.md`, `plan.md`, `BUILD.md`, and this document are not ebook
inputs. The code examples are not automatically included or executed by the
book build; code shown in the manuscript is maintained separately.

## Manuscript coverage

All 12 files listed in `chapters.txt` exist. Their order defines the reading
order, rather than directory or filename sorting.

| Material | Current coverage |
| --- | --- |
| Introduction | Brief prompts and a history heading. |
| How the web works | Partial explanation of clients, servers, HTTP requests, and headers; explicit TODOs and empty HTML/CSS/JavaScript and server sections. |
| Underlying tools | Largest chapter at 352 lines. Substantial Moose examples and an initial DBI/ORM explanation; Perl, Template Toolkit, and PSGI/Plack sections remain empty. |
| Framework overview | Lists the intended frameworks and proposes implementing the same application in each. |
| Plack, Web::Simple, Dancer, Mojolicious, Catalyst | Each framework file currently contains only its heading. |
| Other frameworks | Headings for Squatting, Ox, and further material. |
| Deployment | Introductory paragraph. |
| Code archeology | Introductory paragraph and headings about understanding and migrating CGI applications. |

The framework comparison proposed in the manuscript has not been implemented
across the named frameworks. The checked-in web applications both use Dancer2.

## Ebook build

The build has three output paths:

```text
title.txt + chapters in chapters.txt + metadata.xml + epub.css
    -> pandoc -> perlwebbook.epub
                    -> kindlegen     -> perlwebbook.mobi
                    -> ebook-convert -> perlwebbook.pdf
```

Run from the repository root:

```sh
make          # default: EPUB
make epub     # same output; make book is also an alias
make mobi     # EPUB, then Kindlegen
make pdf      # EPUB, then Calibre's ebook-convert
```

The EPUB command requests a table of contents with two heading levels. Generated
files matching `perlwebbook.*` are ignored by Git. No build target installs
dependencies, runs tests, or deploys anything.

Observed build limitations:

* `make epub` fails with installed Pandoc 3.7.0.2 because `--epub-stylesheet`
  has been removed. Pandoc's error recommends `--css`.
* A temporary build using the same inputs with `--css=epub.css` succeeded.
  Its EPUB ZIP archive passed an integrity check, but this was not an EPUB
  conformance or reader-rendering test.
* That temporary EPUB did not preserve the intended metadata: its language was
  `C`, its date was the build date, and the configured publisher and rights were
  absent. Generating an archive alone is therefore insufficient validation of
  a repaired build.
* `title.txt`, `metadata.xml`, and `chapters.txt` are not declared prerequisites
  of the EPUB target. Changes to them alone may leave an existing output stale.
* `make clean` removes only EPUB and MOBI, omits PDF, and uses `rm` without `-f`,
  so missing files can make cleanup fail. Alias targets are not marked `.PHONY`.
* Kindlegen is not installed in the examined environment. Calibre's
  `ebook-convert` is present, but PDF conversion was not exercised.

## Supporting code

### Moose examples

[Person.pm](code/moose/Person.pm) uses Moose attributes, required values, type
constraints, string-to-DateTime coercion, and an `age` method. Its direct
dependencies include `Moose`, `DateTime`, and `DateTime::Format::Strptime`.

The scripts `person`, `person1`, and `person2` demonstrate construction,
attribute access, and explicit date parsing. `person3` uses automatic date
coercion, `person4` deliberately supplies an invalid value for the class's
`Gender` constraint, and `person5` prints an age. They all use the same current
`Person.pm`, rather than separate versions of the class for each teaching step.

Run from the repository root with the example directory on Perl's include path:

```sh
perl -Icode/moose code/moose/person3
perl -Icode/moose code/moose/person4  # deliberate validation failure
perl -Icode/moose code/moose/person5
```

### Shared web application structure

Both applications use Dancer2 routes, Template Toolkit views with `<% ... %>`
delimiters, `Dancer2::Plugin::DBIC`, DBIx::Class models, and MySQL. In each app:

* `bin/app.psgi` adds the local `lib/` directory, loads the application, and
  returns its PSGI application via `to_app`.
* `config.yml` selects the template engine and database connection;
  `environments/` contains development and production settings.
* `views/` holds templates and a shared layout, and `public/` holds assets,
  error pages, and CGI/FastCGI dispatchers.
* `cpanfile` and `Makefile.PL` provide scaffold-level dependency declarations.
* `t/001_base.t` tests loading the application; `t/002_index_route.t` checks
  that `to_app` returns a coderef and `GET /` succeeds: three assertions per app.

Once dependencies and a matching database are available, the intended local
commands, run from either application's directory, are:

```sh
plackup bin/app.psgi
prove -l t
```

The homepage tests query MySQL. There is no checked-in test database fixture or
mock to make them independent of a configured database.

### BookWeb reading list

The application lives in [code/dancer2/BookWeb/](code/dancer2/BookWeb/), with
routes in [lib/BookWeb.pm](code/dancer2/BookWeb/lib/BookWeb.pm).

| Route | Behavior |
| --- | --- |
| `GET /` | Queries books and renders reading, read, and to-read groups. |
| `POST /search` | Searches Amazon using the supplied keywords and renders results. |
| `GET /add/:isbn` | Looks up an Amazon item, finds or creates its author, and stores the book. |
| `GET /start/:isbn` | Sets the book's `started` timestamp. |
| `GET /end/:isbn` | Sets the book's `ended` timestamp. |
| `GET /login`, `POST /login` | Displays a login form and sets the logged-in session flag for a hard-coded account. |

A before hook allows public access to `/`, `/login`, and `/search`, and forwards
other unauthenticated requests to login. The reading list is shared: there is
no user table or per-user ownership model.

[books.sql](code/dancer2/books.sql) creates a `books` database with `author` and
`book` tables, plus a database user. One author has many books; each book stores
an ISBN, title, optional reading timestamps, and an image URL. Amazon access
uses `Net::Amazon`, the UK locale, and environment variables `AMAZON_KEY`,
`AMAZON_SECRET`, and `AMAZON_ASSTAG`. This integration was not exercised.

### ToDo list

[lib/ToDo.pm](code/todo/ToDo/lib/ToDo.pm) implements only `GET /`: it reads every
`TodoItem` and renders each item's title, description, and priority. There are
no web routes for creating, editing, deleting, or completing items.

[todo.sql](code/todo/db/todo.sql) defines `todo_item` with an ID, title,
description, priority defaulting to 5, and optional due date. It begins by
dropping the `todo` database if it exists; it is a reset script rather than an
incremental migration and was not run during this examination.

[make_item](code/todo/util/make_item) inserts a fixed sample item;
[show_items](code/todo/util/show_items) prints existing items. Both add
`code/todo/lib` to the include path, whereas the schema actually lives under
`code/todo/ToDo/lib`. Running `show_items` directly failed to find
`Todo::Schema`. The schema itself loaded when its actual directory was supplied
with `-Icode/todo/ToDo/lib`.

[dbic.conf](code/todo/db/dbic.conf) records schema-loader settings. Its relative
`lib` paths need to be interpreted against the directory from which the loader
is run. Generated schema files identify their loader-managed sections; custom
changes belong below the generated markers or in the generation inputs.

## Maintenance findings

The most useful follow-up work, in dependency order, is:

1. Repair and verify ebook generation, including EPUB metadata and Makefile
   prerequisites, then check output in a reader.
2. Make sample setup reproducible. The application dependency files omit
   modules used by the examples, including the DBIC plugin, Template Toolkit,
   and app-specific requirements such as `Net::Amazon` and the Cookie session
   engine. Database drivers, date handling, and the ToDo schema's Moose
   components also need to be accounted for. The Dancer2 minimum versions
   differ between apps (`0.159003` and `0.161000`); there is no dependency lock.
3. Repair the ToDo utility include paths and reconcile its generated model
   with SQL: `todo_item.id` is `AUTO_INCREMENT` in SQL, but the model omits
   `is_auto_increment`. Insert behavior was not tested.
4. Address the BookWeb demo's authentication and write operations before using
   it as deployable teaching code: credentials and a cookie signing secret are
   hard-coded; state changes use GET routes without CSRF protection; the login
   redirect accepts a submitted path without validation.
5. Continue the manuscript and review its technical examples. Concrete defects
   include `gender => 'M'm` in `chapters/tools.md` and its statement naming
   `DBD::Sybase` as the Oracle driver. Time-sensitive descriptions, such as the
   HTTP/2 paragraph, also need review.

Neither a root license file nor a manuscript reuse license was found. The
generated application `Makefile.PL` files declare a Perl license, while the
book metadata contains a copyright notice; this does not establish one clear
license for all repository content.

## Verification record

The working tree was clean before examination. Local tools included Perl
5.42.3, Pandoc 3.7.0.2, Make, Prove, Plack, and Calibre's `ebook-convert`.

| Check | Result |
| --- | --- |
| Chapter list | 12 inputs; all exist. |
| `make -n epub mobi pdf` | Confirms the conversion commands and dependency chain. |
| `make epub` | Fails on the removed Pandoc stylesheet option. |
| Temporary EPUB with `--css=epub.css` | Builds; ZIP integrity passes; metadata differs from the configured values. |
| BookWeb: `prove -l t` | 2 of 3 assertions pass; homepage fails on MySQL connection. |
| ToDo: `prove -l t` | 2 of 3 assertions pass; homepage fails on MySQL connection. |
| Moose `person3` | Prints `Friday`. |
| Moose `person4` | Rejects `X` as expected by its explicit type constraint. |
| Moose `person5` | Prints `64` on the examination date. |
| ToDo utility `show_items` | Fails to locate `Todo::Schema` with its built-in include path. |

The app tests were retried outside the sandbox to distinguish access
restrictions from missing infrastructure. Both still failed because the local
MySQL socket `/var/lib/mysql/mysql.sock` did not exist. BookWeb additionally
reported a return-precedence warning and a deprecated DBIC `pass` setting.

No database initialization, application data changes, dependency installation,
or external API requests were performed. The temporary EPUB was removed after
inspection. This examination changes only documentation.
