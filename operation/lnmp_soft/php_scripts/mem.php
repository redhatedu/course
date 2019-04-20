<?php
$memcache=new Memcache;
$memcache->connect('localhost',11211) or die ('could not connect!! ');
$memcache->set('key', 'test');
$get_values=$memcache->get('key');
echo $get_values;
?>

