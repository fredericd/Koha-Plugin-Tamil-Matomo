package Koha::Plugin::Tamil::Matomo;

use Modern::Perl;
use utf8;
use base qw(Koha::Plugins::Base);
use CGI qw(-utf8);
use Koha::Cache;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use Template;
use JSON qw/ to_json /;
use List::Util qw/ first /;
use Pithub::Markdown;
use YAML;



## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'Tamil Matomo',
    canonicalname   => 'koha-plugin-tamil-matomo',
    description     => 'Interfaçage entre Koha et Matomo',
    author          => 'Tamil s.a.r.l.',
    date_authored   => '2025-12-10',
    date_updated    => "2025-12-10",
    minimum_version => '24.11.00.000',
    maximum_version => undef,
    copyright       => '2025',
    version         => '1.0.1',
};


sub new {
    my ($class, $args) = @_;

    $args->{metadata} = $metadata;
    $args->{metadata}->{class} = $class;
    $args->{cache} = Koha::Cache->new();
    $args->{logger} = Koha::Logger->get({ interface => 'api' });

    $class->SUPER::new($args);
}


sub config {
    my $self = shift;

    my $c = $self->{args}->{c};
    unless ($c) {
        $c = $self->retrieve_data('c');
        if ($c) {
            utf8::encode($c);
            $c = decode_json($c);
        }
        else {
            $c = {};
        }
    }
    $c->{matomo} ||= {};
    $c->{matomo}->{url} ||= '//matomo.tamil.fr';
    $c->{matomo}->{siteid} ||= '1';

    $c->{opac}->{page}->{main}->{id}           = 'opac-main';
    $c->{opac}->{page}->{main}->{title}      ||= 'Accueil OPAC';
    $c->{opac}->{page}->{advsearch}->{id}      = 'advsearch';
    $c->{opac}->{page}->{advsearch}->{title} ||= 'Recherche avancée';
    $c->{opac}->{page}->{results}->{id}        = 'results';
    $c->{opac}->{page}->{results}->{title}   ||= 'Résultat recherche';
    $c->{opac}->{page}->{detail}->{id}         = 'opac-detail';
    $c->{opac}->{page}->{detail}->{title}    ||= 'Notice';
    $c->{opac}->{page}->{page}->{id}           = 'opac-page';
    $c->{opac}->{page}->{page}->{title}      ||= 'Page';

    $c->{metadata} = $self->{metadata};

    $self->{args}->{c} = $c;

    return $c;
}


sub get_form_config {
    my $cgi = shift;
    my $c = {
        matomo => {
            url => undef,
            siteid => undef,
        },
        opac => {
            enable => undef,
            page => {
                main      => { title => undef },
                advsearch => { title => undef },
                results   => { title => undef },
                detail    => { title => undef },
                page      => { title => undef },
            },
        },
    };

    my $set;
    $set = sub {
        my ($node, $path) = @_;
        return if ref($node) ne 'HASH';
        for my $subkey ( keys %$node ) {
            my $key = $path ? "$path.$subkey" : $subkey;
            my $subnode = $node->{$subkey};
            if ( ref($subnode) eq 'HASH' ) {
                $set->($subnode, $key);
            }
            else {
                #my $value = $cgi->param("$key");
                #$value = '' unless defined($value);
                #$node->{$subkey} = $value;
                my @values = $cgi->multi_param("$key");
                @values = map { s/\r//g; $_; } @values;
                $node->{$subkey} = join(',', @values);
            }
        }
    };

    $set->($c);
    return $c;
}


sub configure {
    my ($self, $args) = @_;
    my $cgi = $self->{'cgi'};
    my $op  = $cgi->param('op') // q{};

    if ( $op eq 'cud-save' ) {
        my $c = get_form_config($cgi);
        $self->store_data({ c => encode_json($c) });
        $self->{cache}->clear_from_cache('matomo-js');
        print $self->{'cgi'}->redirect(
            "/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::Tamil::Matomo&method=tool");
    }
    else {
        my $template = $self->get_template({ file => 'configure.tt' });
        $template->param( c => $self->config() );
        $self->output_html( $template->output() );
    }
}


sub install() {
    my ($self, $args) = @_;
}


sub upgrade {
    my ($self, $args) = @_;

    my $dt = DateTime->now();
    $self->store_data( { last_upgraded => $dt->ymd('-') . ' ' . $dt->hms(':') } );

    return 1;
}


sub uninstall() {
    my ($self, $args) = @_;
}


sub tool {
    my ($self, $args) = @_;

    my $cgi = $self->{'cgi'};

    my $template;
    my $tool = $cgi->param('tool');
    if ( $tool ) {
        # One day, maybe
    }
    else {
        $template = $self->get_template({ file => 'home.tt' });
        my $cache = $self->{cache};
        my $key = "matomo-home";
        my $markdown = $cache->get_from_cache($key);
        unless ($markdown) {
            my $text = $self->mbf_read("home.md");
            utf8::decode($text);
            my $response = Pithub::Markdown->new->render(
                data => {
                    text => $text,
                    context => "github/gollum",
                },
            );
            $markdown = $response->raw_content;
            utf8::decode($markdown);
            $cache->set_in_cache($key, $markdown, { expiry => 3600 });
        }
        $template->param( markdown => $markdown );
    }
    $template->param( c => $self->config() );
    $template->param( TOOL => $tool ) if $tool;
    $self->output_html( $template->output() );
}


sub opac_js {
    my $self = shift;

  	my $c = $self->config;
    my $logger = Koha::Logger->get({ interface => 'api' });

    unless ($c->{opac}->{enable}) {
        $logger->debug("Matomo tracker désactivé à l'OPAC");
        return '';
    }

    my $cache = $self->{cache};
    my $key = "matomo-js";
    my $js = $cache->get_from_cache($key);

    if ($js) {
        $logger->debug('Récupération en cache de matomo.js');
    }
    else {
        $logger->debug('Lecture et mise en cache de matomo.js');
        my $js = $self->mbf_read('matomo.js');
        utf8::decode($js);
        my $json = to_json($c);
        $js = <<EOS;
<script>
let tamil_matomo_conf = $json;
$js
</script>
EOS
        $cache->set_in_cache($key, $js, { expiry => 3600 });
    }

    return $js;
}

1;
