use Mojolicious::Lite -signatures;
use Mojo::Redis;

my $redis = Mojo::Redis->new;


websocket '/echo' => sub ($c) {
  $c->inactivity_timeout(300);
  $redis->db->incr('conn');
  $c->on(message => sub ($c, $msg) {
      $c->app->log->debug('Websocket opened');
      $c->send("echo $msg");
  });
  $c->on(finish => sub($c, $code, $reason = undef) {
      $redis->db->decr('conn');
      $c->app->log->debug("Websocket closed with status $code");
  })
};


app->start;
