package BookWeb;
use Dancer2;
#use Dancer2::Session;
use Dancer2::Plugin::DBIC;
use Net::Amazon;
use DateTime;

our $VERSION = '0.1';

sub get_amazon {
     return Net::Amazon->new(
        token         => $ENV{AMAZON_KEY},
        secret_key    => $ENV{AMAZON_SECRET},
        associate_tag => $ENV{AMAZON_ASSTAG},
        locale        => 'uk',
    ) or die "Cannot connect to Amazon\n";
}

my %public_path = map { $_ => 1 } ('/', '/login', '/search');
 
hook before => sub {
  if (! session('logged_in') and
      ! $public_path{request->path_info}) {
      var requested_path => request->path_info;
      forward '/login';
  }
};

get '/' => sub {
  my $books_rs = schema->resultset('Book');
 
  my @reading = $books_rs->search({
    started => { '!=', undef },
    ended => undef,
  });
 
  my @read = $books_rs->search({
    ended => { '!=', undef },
  });
 
  my @to_read = $books_rs->search({
    started => undef,
  });
 
  template 'index', {
    reading => \@reading,
    read    => \@read,
    to_read => \@to_read,
  };
};

get '/start/:isbn' => sub {
 
  my $books_rs = schema->resultset('Book');
  my $book = $books_rs->find({ isbn => param('isbn')});
 
  if ($book) {
    $book->update({started => DateTime->now});
  }
 
  return redirect '/';
};

get '/end/:isbn' => sub {
 
  my $books_rs = schema->resultset('Book');
  my $book = $books_rs->find({ isbn => param('isbn')});
 
  if ($book) {
    $book->update({ended => DateTime->now});
  }
 
  return redirect '/';
};

get '/add/:isbn' => sub {
    my $author_rs = schema->resultset('Author');
 
    my $amz = get_amazon();
 
    # Search for the book at Amazon
    my $resp = $amz->search(asin => param('isbn'));
 
    unless ($resp->is_success) {
        die 'Error: ', $resp->message;
    }
 
    my $book        = $resp->properties;
    my $title       = $book->ProductName;
    my $author_name = ($book->authors)[0];
    my $imgurl      = $book->ImageUrlMedium;
 
    # Find or create the author
    my $author = $author_rs->find_or_create({
        name => $author_name,
    });
 
    # Add the book to the author
    $author->add_to_books({
        isbn      => param('isbn'),
        title     => $title,
        image_url => $imgurl,
    });
 
    return redirect '/';
};

post '/search' => sub {
  my $amz = get_amazon();
  
  my $resp = $amz->search(
    keyword => param('search'),
    mode    => 'books',
  );
 
  my %data;
  $data{search} = param('search');
  if ($resp->is_success) {
    $data{books} = [ $resp->properties ];
  } else {
    $data{error} = $resp->message;
  }
 
  template 'results', \%data;
};

get '/login' => sub {
    template 'login', { path => vars->{requested_path } };  
};
 
post '/login' => sub {
    if (params->{user} eq 'reader' && params->{pass} eq 'letmein') {
        session 'logged_in' => 1;
    }
 
    redirect  params->{path} || '/';
};

true;
