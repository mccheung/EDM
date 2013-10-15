package EDM;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('root#index');
  $r->get('/oauth2')->to('oauth2#index');
  $r->post('/oauth2')->to('oauth2#oauth2');
}

1;
