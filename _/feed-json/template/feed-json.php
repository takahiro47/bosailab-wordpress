<?php
/**
 * JSON Feed Template for displaying JSON Posts feed.
 *
 */
$callback = trim(esc_html(get_query_var('callback')));
$charset  = get_bloginfo('charset');

if (!function_exists('json_encode')) {
  // For PHP < 5.2.0
  function json_encode( $string ) {
    if ( !class_exists('Services_JSON') ) {
      require_once( 'class-json.php' );
    }
    $json = new Services_JSON();
    return $json->encode( $string );
  }
}

if ( have_posts() ) {

  global $wp_query, $fj_feed_json;
  $query_array = $wp_query->query;

  // Make sure query args are always in the same order
  ksort( $query_array );

  $json = array();

  while ( have_posts() ) {
    the_post();
    $id = (int) $post->ID;

    $response = array(
      'id'                => $id,
      'title'             => get_the_title(),
      'permalink'         => get_permalink(),
      'content'           => get_the_content(),
      'excerpt'           => get_the_excerpt(),
      'datetime'          => array(
        'format'            => get_the_date('Y/m/d H:i:s', '', '', false),
      ),
    );

    if ( is_ ) {

    }
    if ( is_page( 'about' ) ) {
      $members = explode( '<br />', get_field( 'member_lists' ) ); // とりあえず行に分割
      $members = array_map( 'trim', $members ); // 各要素をtrim()にかける
      $members = array_filter( $members, 'strlen' ); // 文字数が0のものを取り除く
      $members = array_values( $members ); // キーを連番に振りなおす

      $response['page'] = array(
        'about_the_lab'       => get_field( 'about_the_lab' ),
        'professor_face'      => get_field( 'professor_face' ),
        'about_the_professor' => get_field( 'about_the_professor' ),
        'member_face'         => get_field( 'member_face' ),
        'members'             => $members,
        'member'              => get_field( 'member' ),
        'join_us'             => get_field( 'join_us' ),
      );
    } elseif ( is_page() ) {
      $response['page'] = array(
        'content'             => get_the_content(),
      );
    }

    // thumbnail
    if (function_exists('has_post_thumbnail') && has_post_thumbnail($id)) {
      $response["thumbnail"] = preg_replace("/^.*['\"](https?:\/\/[^'\"]*)['\"].*/i","$1",get_the_post_thumbnail($id));
    }

    // category
    $response["categories"] = array();
    $categories = get_the_category();
    if ( ! empty( $categories ) ) {
      $response["categories"] = wp_list_pluck( $categories, 'cat_name' );
    }

    // tags
    $response["tags"] = array();
    $tags = get_the_tags();
    if ( ! empty( $tags) ) {
      $response["tags"] = wp_list_pluck( $tags, 'name' );
    }

    $json[] = $response;
  }

  $json = json_encode($json);

  nocache_headers();
  if (!empty($callback)) {
    header("Content-Type: application/x-javascript; charset={$charset}");
    echo "{$callback}({$json});";
  } else {
    header("Content-Type: application/json; charset={$charset}");
    echo $json;
  }

} else {
  header("HTTP/1.0 404 Not Found");
  wp_die("404 Not Found");
}
