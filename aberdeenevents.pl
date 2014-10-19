#!/usr/bin/perl 

use strict;
use warnings;

use JSON;
use LWP::Simple;
use LWP::UserAgent;
use WWW;

my $url     = "http://matchthecity.org/regions/1/opportunities.json";
my $json =  get($url);

my $arrayref = decode_json $json;

my $feed ="";

my $imm;
my $ven_feed = "";
my $ven_web = "";


/* credentials for this are obtained from the dev.twitter.com page after logging in as the twitter user*/
my $nt = WWW->new(
        traits=> [qw/API::RESTv1_1/],
        consumer_key=> 'XXXXX',
        consumer_secret => 'YYYY',
        access_token=> 'ZZZZ',
        access_token_secret => 'AAAA',
        ssl=>1 ,
 );

/*this is the Bing api setup from the dev bing page listed*/
my $key= "BBBB";
my $server= 'api.datamarket.azure.com';

my $href;

my $search_word1 = "";



foreach my $item( @$arrayref ) { 

my $venue = $item->{venue};

foreach my $ven($venue){
$ven_feed = $ven->{name};
$ven_web = $ven->{web};
}


$feed =  $ven_feed."\n".$item->{name}."\n".$item->{day_of_week}."-".$item->{start_time}."\n".$ven_web."\n"."#Aberdeen"."\n";

	$search_word1 = $item->{name};

my $get_image_number = int(rand(6));

	my $href1= qq(https://api.datamarket.azure.com/Bing/Search/v1/Composite?Sources=%27image%27&Query=%27$search_word1%27&ImageFilters=%27Size:Large%27&\$format=JSON&\$top=$get_image_number);


	my $ua1= LWP::UserAgent->new();
	   $ua1->credentials($server.':443', '', '', $key);
	my $body1= $ua1->get($href1);

	my $json1 = from_json($body1->content);

	my $imm1;
	my $contenttype1;

	foreach my $result1 ( @{ $json1->{d}->{results} } )
	{
		my $image1 = $result1->{Image};

		foreach my $im1 ( @{ $image1 } )
		{
			$imm1 = $im1->{MediaUrl};
			$contenttype1 = $im1->{ContentType};
		}
	}


	getstore($imm1,"image1.png");


if (-e "image1.png")
 {
	 $nt->update_with_media($feed, ["image1.png"]);
	 unlink "image1.png";
 }
 else
 {
	 $nt->update_with_media($feed, ["aber.jpg"]);
	 
	 
	/* aber.jpg is a random google image of Aberdeen residing in the subdirectory
	 and used if a random image is not found */
	 
	 
 }

}
