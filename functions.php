<?php
/**
 * Twenty Thirteen functions and definitions.
 *
 * Sets up the theme and provides some helper functions, which are used in the
 * theme as custom template tags. Others are attached to action and filter
 * hooks in WordPress to change core functionality.
 *
 * When using a child theme (see http://codex.wordpress.org/Theme_Development
 * and http://codex.wordpress.org/Child_Themes), you can override certain
 * functions (those wrapped in a function_exists() call) by defining them first
 * in your child theme's functions.php file. The child theme's functions.php
 * file is included before the parent theme's file, so the child theme
 * functions would be used.
 *
 * Functions that are not pluggable (not wrapped in function_exists()) are
 * instead attached to a filter or action hook.
 *
 * For more information on hooks, actions, and filters,
 * see http://codex.wordpress.org/Plugin_API
 *
 * @package WordPress
 * @subpackage SFC_Bosalab_2013
 * @since 1.0
 */

/**
 * Sets up the content width value based on the theme's design.
 * @see twentythirteen_content_width() for template-specific adjustments.
 */
if ( ! isset( $content_width ) )
  $content_width = 604;

/**
 * Adds support for a custom header image.
 */
require get_template_directory() . '/inc/custom-header.php';

/**
 * Twenty Thirteen only works in WordPress 3.6 or later.
 */
if ( version_compare( $GLOBALS['wp_version'], '3.6-alpha', '<' ) )
  require get_template_directory() . '/inc/back-compat.php';

/**
 * Sets up theme defaults and registers the various WordPress features that
 * Twenty Thirteen supports.
 *
 * @uses load_theme_textdomain() For translation/localization support.
 * @uses add_editor_style() To add Visual Editor stylesheets.
 * @uses add_theme_support() To add support for automatic feed links, post
 * formats, and post thumbnails.
 * @uses register_nav_menu() To add support for a navigation menu.
 * @uses set_post_thumbnail_size() To set a custom post thumbnail size.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_setup() {
  /*
   * Makes Twenty Thirteen available for translation.
   *
   * Translations can be added to the /languages/ directory.
   * If you're building a theme based on Twenty Thirteen, use a find and
   * replace to change 'twentythirteen' to the name of your theme in all
   * template files.
   */
  load_theme_textdomain( 'twentythirteen', get_template_directory() . '/languages' );

  /*
   * This theme styles the visual editor to resemble the theme style,
   * specifically font, colors, icons, and column width.
   */
  // add_editor_style( array( '/dist/css/editor-style.css', '/dist/fonts/genericons.css', twentythirteen_fonts_url() ) );

  // Adds RSS feed links to <head> for posts and comments.
  // add_theme_support( 'automatic-feed-links' );

  // Switches default core markup for search form, comment form, and comments
  // to output valid HTML5.
  // add_theme_support( 'html5', array( 'search-form', 'comment-form', 'comment-list' ) );

  /*
   * This theme supports all available post formats by default.
   * See http://codex.wordpress.org/Post_Formats
   */
  // add_theme_support( 'post-formats', array(
  //   'aside', 'audio', 'chat', 'gallery', 'image', 'link', 'quote', 'status', 'video'
  // ) );

  // This theme uses wp_nav_menu() in one location.
  register_nav_menu( 'primary_left', 'ヘッダナビ(タイトルロゴの左)' );

  register_nav_menu( 'primary_right', 'ヘッダナビ(タイトルロゴの右)' );

  /*
   * This theme uses a custom image size for featured images, displayed on
   * "standard" posts and pages.
   */
  // add_theme_support( 'post-thumbnails' );
  // set_post_thumbnail_size( 604, 270, true );

  // This theme uses its own gallery styles.
  // add_filter( 'use_default_gallery_style', '__return_false' );
}
add_action( 'after_setup_theme', 'twentythirteen_setup' );

/**
 * Enqueues scripts and styles for front end.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_scripts_styles() {
  // Adds JavaScript to pages with the comment form to support sites with
  // threaded comments (when in use).
  // if ( is_singular() && comments_open() && get_option( 'thread_comments' ) )
  //   wp_enqueue_script( 'comment-reply' );

  // Adds Masonry to handle vertical alignment of footer widgets.
  if ( is_active_sidebar( 'sidebar-1' ) )
    wp_enqueue_script( 'jquery-masonry' );

  // Loads JavaScript file with functionality specific to Twenty Thirteen.
  // wp_enqueue_script( 'theme-script', get_template_directory_uri() . '/dist/js/functions.js', array( 'jquery' ), '2013', true );

  // Original Scripts.
  // wp_enqueue_script( 'script', get_template_directory_uri() . '/dist/js/script.js', array( 'jquery' ), '2013', true );

  // Add Open Sans and Bitter fonts, used in the main stylesheet.
  // wp_enqueue_style( 'theme-fonts', twentythirteen_fonts_url(), array(), null );

  // Add Genericons font, used in the main stylesheet.
  // wp_enqueue_style( 'genericons', get_template_directory_uri() . '/fonts/genericons.css', array(), '2.09' );

  // Loads our main stylesheet.
  // wp_enqueue_style( 'theme-style', get_stylesheet_uri(), array(), '2013-07-18' );

  // Original Stylesheets.
  // wp_enqueue_style( 'style', get_template_directory_uri() . '/dist/css/style.css', array(), '2013-11-08' );

  // Loads the Internet Explorer specific stylesheet.
  // wp_enqueue_style( 'twentythirteen-ie', get_template_directory_uri() . '/dist/css/ie.css', array( 'twentythirteen-style' ), '2013-07-18' );
  // wp_style_add_data( 'twentythirteen-ie', 'conditional', 'lt IE 9' );
}
add_action( 'wp_enqueue_scripts', 'twentythirteen_scripts_styles' );

/**
 * Creates a nicely formatted and more specific title element text for output
 * in head of document, based on current view.
 *
 * @since 1.0
 *
 * @param string $title Default title text for current view.
 * @param string $sep Optional separator.
 * @return string The filtered title.
 */
function twentythirteen_wp_title( $title, $sep ) {
  global $paged, $page;

  if ( is_feed() )
    return $title;

  // Add the site name.
  $title .= get_bloginfo( 'name' );

  // Add the site description for the home/front page.
  $site_description = get_bloginfo( 'description', 'display' );
  if ( $site_description && ( is_home() || is_front_page() ) )
    $title = "$title $sep $site_description";

  // Add a page number if necessary.
  if ( $paged >= 2 || $page >= 2 )
    $title = "$title $sep " . sprintf( __( 'Page %s', 'twentythirteen' ), max( $paged, $page ) );

  return $title;
}
add_filter( 'wp_title', 'twentythirteen_wp_title', 10, 2 );

/**
 * Registers two widget areas.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_widgets_init() {
  register_sidebar( array(
    'name'          => __( 'Main Widget Area', 'twentythirteen' ),
    'id'            => 'sidebar-1',
    'description'   => __( 'Appears in the footer section of the site.', 'twentythirteen' ),
    'before_widget' => '<aside id="%1$s" class="widget %2$s">',
    'after_widget'  => '</aside>',
    'before_title'  => '<h3 class="widget-title">',
    'after_title'   => '</h3>',
  ) );

  register_sidebar( array(
    'name'          => __( 'Secondary Widget Area', 'twentythirteen' ),
    'id'            => 'sidebar-2',
    'description'   => __( 'Appears on posts and pages in the sidebar.', 'twentythirteen' ),
    'before_widget' => '<aside id="%1$s" class="widget %2$s">',
    'after_widget'  => '</aside>',
    'before_title'  => '<h3 class="widget-title">',
    'after_title'   => '</h3>',
  ) );
}
add_action( 'widgets_init', 'twentythirteen_widgets_init' );

if ( ! function_exists( 'twentythirteen_paging_nav' ) ) :
/**
 * Displays navigation to next/previous set of posts when applicable.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_paging_nav() {
  global $wp_query;

  // Don't print empty markup if there's only one page.
  if ( $wp_query->max_num_pages < 2 )
    return;
  ?>
  <nav class="navigation paging-navigation" role="navigation">
    <h1 class="screen-reader-text"><?php _e( 'Posts navigation', 'twentythirteen' ); ?></h1>
    <div class="nav-links">

      <?php if ( get_next_posts_link() ) : ?>
      <div class="nav-previous"><?php next_posts_link( __( '<span class="meta-nav">&larr;</span> Older posts', 'twentythirteen' ) ); ?></div>
      <?php endif; ?>

      <?php if ( get_previous_posts_link() ) : ?>
      <div class="nav-next"><?php previous_posts_link( __( 'Newer posts <span class="meta-nav">&rarr;</span>', 'twentythirteen' ) ); ?></div>
      <?php endif; ?>

    </div><!-- .nav-links -->
  </nav><!-- .navigation -->
  <?php
}
endif;

if ( ! function_exists( 'twentythirteen_post_nav' ) ) :
/**
 * Displays navigation to next/previous post when applicable.
*
* @since 1.0
*
* @return void
*/
function twentythirteen_post_nav() {
  global $post;

  // Don't print empty markup if there's nowhere to navigate.
  $previous = ( is_attachment() ) ? get_post( $post->post_parent ) : get_adjacent_post( false, '', true );
  $next     = get_adjacent_post( false, '', false );

  if ( ! $next && ! $previous )
    return;
  ?>
  <nav class="navigation post-navigation" role="navigation">
    <h1 class="screen-reader-text"><?php _e( 'Post navigation', 'twentythirteen' ); ?></h1>
    <div class="nav-links">

      <?php previous_post_link( '%link', _x( '<span class="meta-nav">&larr;</span> %title', 'Previous post link', 'twentythirteen' ) ); ?>
      <?php next_post_link( '%link', _x( '%title <span class="meta-nav">&rarr;</span>', 'Next post link', 'twentythirteen' ) ); ?>

    </div><!-- .nav-links -->
  </nav><!-- .navigation -->
  <?php
}
endif;

if ( ! function_exists( 'twentythirteen_entry_meta' ) ) :
/**
 * Prints HTML with meta information for current post: categories, tags, permalink, author, and date.
 *
 * Create your own twentythirteen_entry_meta() to override in a child theme.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_entry_meta() {
  if ( is_sticky() && is_home() && ! is_paged() )
    echo '<span class="featured-post">' . __( 'Sticky', 'twentythirteen' ) . '</span>';

  if ( ! has_post_format( 'link' ) && 'post' == get_post_type() )
    twentythirteen_entry_date();

  // Translators: used between list items, there is a space after the comma.
  $categories_list = get_the_category_list( __( ', ', 'twentythirteen' ) );
  if ( $categories_list ) {
    echo '<span class="categories-links">' . $categories_list . '</span>';
  }

  // Translators: used between list items, there is a space after the comma.
  $tag_list = get_the_tag_list( '', __( ', ', 'twentythirteen' ) );
  if ( $tag_list ) {
    echo '<span class="tags-links">' . $tag_list . '</span>';
  }

  // Post author
  if ( 'post' == get_post_type() ) {
    printf( '<span class="author vcard"><a class="url fn n" href="%1$s" title="%2$s" rel="author">%3$s</a></span>',
      esc_url( get_author_posts_url( get_the_author_meta( 'ID' ) ) ),
      esc_attr( sprintf( __( 'View all posts by %s', 'twentythirteen' ), get_the_author() ) ),
      get_the_author()
    );
  }
}
endif;

if ( ! function_exists( 'twentythirteen_entry_date' ) ) :
/**
 * Prints HTML with date information for current post.
 *
 * Create your own twentythirteen_entry_date() to override in a child theme.
 *
 * @since 1.0
 *
 * @param boolean $echo Whether to echo the date. Default true.
 * @return string The HTML-formatted post date.
 */
function twentythirteen_entry_date( $echo = true ) {
  if ( has_post_format( array( 'chat', 'status' ) ) )
    $format_prefix = _x( '%1$s on %2$s', '1: post format name. 2: date', 'twentythirteen' );
  else
    $format_prefix = '%2$s';

  $date = sprintf( '<span class="date"><a href="%1$s" title="%2$s" rel="bookmark"><time class="entry-date" datetime="%3$s">%4$s</time></a></span>',
    esc_url( get_permalink() ),
    esc_attr( sprintf( __( 'Permalink to %s', 'twentythirteen' ), the_title_attribute( 'echo=0' ) ) ),
    esc_attr( get_the_date( 'c' ) ),
    esc_html( sprintf( $format_prefix, get_post_format_string( get_post_format() ), get_the_date() ) )
  );

  if ( $echo )
    echo $date;

  return $date;
}
endif;

if ( ! function_exists( 'twentythirteen_the_attached_image' ) ) :
/**
 * Prints the attached image with a link to the next attached image.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_the_attached_image() {
  $post                = get_post();
  $attachment_size     = apply_filters( 'twentythirteen_attachment_size', array( 724, 724 ) );
  $next_attachment_url = wp_get_attachment_url();

  /**
   * Grab the IDs of all the image attachments in a gallery so we can get the URL
   * of the next adjacent image in a gallery, or the first image (if we're
   * looking at the last image in a gallery), or, in a gallery of one, just the
   * link to that image file.
   */
  $attachment_ids = get_posts( array(
    'post_parent'    => $post->post_parent,
    'fields'         => 'ids',
    'numberposts'    => -1,
    'post_status'    => 'inherit',
    'post_type'      => 'attachment',
    'post_mime_type' => 'image',
    'order'          => 'ASC',
    'orderby'        => 'menu_order ID'
  ) );

  // If there is more than 1 attachment in a gallery...
  if ( count( $attachment_ids ) > 1 ) {
    foreach ( $attachment_ids as $attachment_id ) {
      if ( $attachment_id == $post->ID ) {
        $next_id = current( $attachment_ids );
        break;
      }
    }

    // get the URL of the next image attachment...
    if ( $next_id )
      $next_attachment_url = get_attachment_link( $next_id );

    // or get the URL of the first image attachment.
    else
      $next_attachment_url = get_attachment_link( array_shift( $attachment_ids ) );
  }

  printf( '<a href="%1$s" title="%2$s" rel="attachment">%3$s</a>',
    esc_url( $next_attachment_url ),
    the_title_attribute( array( 'echo' => false ) ),
    wp_get_attachment_image( $post->ID, $attachment_size )
  );
}
endif;

/**
 * Returns the URL from the post.
 *
 * @uses get_url_in_content() to get the URL in the post meta (if it exists) or
 * the first link found in the post content.
 *
 * Falls back to the post permalink if no URL is found in the post.
 *
 * @since 1.0
 *
 * @return string The Link format URL.
 */
function twentythirteen_get_link_url() {
  $content = get_the_content();
  $has_url = get_url_in_content( $content );

  return ( $has_url ) ? $has_url : apply_filters( 'the_permalink', get_permalink() );
}

/**
 * Extends the default WordPress body classes.
 *
 * Adds body classes to denote:
 * 1. Single or multiple authors.
 * 2. Active widgets in the sidebar to change the layout and spacing.
 * 3. When avatars are disabled in discussion settings.
 *
 * @since 1.0
 *
 * @param array $classes A list of existing body class values.
 * @return array The filtered body class list.
 */
function twentythirteen_body_class( $classes ) {
  if ( ! is_multi_author() )
    $classes[] = 'single-author';

  if ( is_active_sidebar( 'sidebar-2' ) && ! is_attachment() && ! is_404() )
    $classes[] = 'sidebar';

  if ( ! get_option( 'show_avatars' ) )
    $classes[] = 'no-avatars';

  return $classes;
}
add_filter( 'body_class', 'twentythirteen_body_class' );

/**
 * Adjusts content_width value for video post formats and attachment templates.
 *
 * @since 1.0
 *
 * @return void
 */
function twentythirteen_content_width() {
  global $content_width;

  if ( is_attachment() )
    $content_width = 724;
  elseif ( has_post_format( 'audio' ) )
    $content_width = 484;
}
add_action( 'template_redirect', 'twentythirteen_content_width' );

/**
 * Add postMessage support for site title and description for the Customizer.
 *
 * @since 1.0
 *
 * @param WP_Customize_Manager $wp_customize Customizer object.
 * @return void
 */
function twentythirteen_customize_register( $wp_customize ) {
  $wp_customize->get_setting( 'blogname' )->transport         = 'postMessage';
  $wp_customize->get_setting( 'blogdescription' )->transport  = 'postMessage';
  $wp_customize->get_setting( 'header_textcolor' )->transport = 'postMessage';
}
add_action( 'customize_register', 'twentythirteen_customize_register' );

/**
 * Binds JavaScript handlers to make Customizer preview reload changes
 * asynchronously.
 *
 * @since 1.0
 */
function twentythirteen_customize_preview_js() {
  wp_enqueue_script( 'twentythirteen-customizer', get_template_directory_uri() . '/dist/js/theme-customizer.js', array( 'customize-preview' ), '20130226', true );
}
add_action( 'customize_preview_init', 'twentythirteen_customize_preview_js' );





/* =============================================
 * 管理画面まわり
 * http://www.nxworld.net/wordpress/wp-admin-customize-hack2.html
 * ============================================= */
// アップデート情報非表示(本体)
if ( !current_user_can('administrator') ) {
  add_filter('pre_site_transient_update_core', create_function('$a', "return null;"));
}

// アップデート情報非表示(プラグイン)
function remove_counts(){
  global $menu,$submenu;
  $menu[65][0] = 'プラグイン';
  $submenu['index.php'][10][0] = 'Updates';
}
add_action('admin_menu', 'remove_counts');

// サイドバーの項目を非表示
function remove_menu() {
  /* サイドバーの項目を非表示 */
  // remove_menu_page('index.php');                // ダッシュボード
  remove_menu_page('edit.php');                 // 投稿
  // remove_menu_page('upload.php');               // メディア
  // remove_menu_page('link-manager.php');         // リンク
  // remove_menu_page('edit.php?post_type=page');  // 固定ページ
  remove_menu_page('edit-comments.php');        // コメント
  // remove_menu_page('themes.php');               // 外観
  // remove_menu_page('plugins.php');              // プラグイン
  // remove_menu_page('users.php');                // ユーザー
  // remove_menu_page('tools.php');                // ツール
  // remove_menu_page('options-general.php');      // 設定

  /* サイドバーの項目のサブメニューを非表示 */
  // ダッシュボードの「更新」を非表示
  remove_submenu_page('index.php', 'update-core.php');
  // 投稿の「タグ」を非表示
  remove_submenu_page('edit.php', 'edit-tags.php?taxonomy=post_tag');
}
add_action('admin_menu', 'remove_menu');

// 編集画面から不要なボックスを非表示(投稿)
function remove_default_post_screen_metaboxes() {
  remove_meta_box( 'postexcerpt','post','normal' );       // 抜粋
  remove_meta_box( 'trackbacksdiv','post','normal' );     // トラックバック送信
  remove_meta_box( 'postcustom','post','normal' );        // カスタムフィールド
  remove_meta_box( 'commentstatusdiv','post','normal' );  // ディスカッション
  remove_meta_box( 'commentsdiv','post','normal' );       // コメント
  remove_meta_box( 'slugdiv','post','normal' );           // スラッグ
  remove_meta_box( 'authordiv','post','normal' );         // 作成者
  // remove_meta_box( 'revisionsdiv','post','normal' );      // リビジョン
  remove_meta_box( 'formatdiv','post','normal' );         // フォーマット
  // remove_meta_box( 'categorydiv','post','normal' );       // カテゴリー
  // remove_meta_box( 'tagsdiv-post_tag','post','normal' );  // タグ
}
add_action('admin_menu', 'remove_default_post_screen_metaboxes');

// 編集画面から不要なボックスを非表示(固定ページ)
function remove_default_page_screen_metaboxes() {
  // remove_meta_box( 'postcustom','page','normal' );        // カスタムフィールド
  remove_meta_box( 'commentstatusdiv','page','normal' );  // ディスカッション
  remove_meta_box( 'commentsdiv','page','normal' );       // コメント
  remove_meta_box( 'slugdiv','page','normal' );           // スラッグ
  remove_meta_box( 'authordiv','page','normal' );         // 作成者
  // remove_meta_box( 'revisionsdiv','page','normal' );      // リビジョン
}
add_action('admin_menu', 'remove_default_page_screen_metaboxes');

// 一覧の不要な項目を非表示(投稿)
function custom_posts_columns ($columns) {
  // unset($columns['cb']);          // チェックボックス
  // unset($columns['title']);       // タイトル
  unset($columns['author']);      // 作成者
  // unset($columns['categories']);  // カテゴリー
  unset($columns['tags']);        // タグ
  unset($columns['comments']);    // コメント
  // unset($columns['date']);        // 日付
  return $columns;
}
add_filter('manage_posts_columns', 'custom_posts_columns');
// add_action( 'manage_posts_custom_column', 'custom_posts_columns');

// 一覧の不要な項目を非表示(固定ページ)
function custom_pages_columns ($columns) {
  // unset($columns['cb']);          // チェックボックス
  // unset($columns['title']);       // タイトル
  unset($columns['author']);      // 作成者
  unset($columns['categories']);  // カテゴリー
  unset($columns['tags']);        // タグ
  unset($columns['comments']);    // コメント
  unset($columns['date']);        // 日付
  return $columns;
}
add_filter('manage_pages_columns', 'custom_pages_columns');

// 投稿一覧、固定ページ一覧に項目を追加(カスタム投稿フィールド)
add_theme_support( 'post-thumbnails' );
function manage_posts_columns($columns) {
  $columns['thumbnail'] = __('Thumbnail');
  $columns['photo'] = "写真";
  $columns['responsibility'] = "文責";
  // $columns['members'] = "参加者";
  return $columns;
}

// 投稿一覧、固定ページ一覧に項目を追加(アイキャッチ)
function add_column($column_name, $post_id) {
  // カスタムフィールド取得
  if( $column_name == 'responsibility' ) {
    $responsibility = get_post_meta($post_id, 'responsibility', true);
  }
  if( $column_name == 'photo' ) {
    $photo = '<img src="'.get_field('photo').'">'; //get_post_meta($post_id, 'photo', true);
  }
  // アイキャッチ取得
  if ( 'thumbnail' == $column_name) {
    $thum = get_the_post_thumbnail($post_id, array(72, 72), 'thumbnail');
  }
  // 使用していない場合「なし」を表示
  if ( isset($responsibility) and $responsibility ) {
    echo attribute_escape( $responsibility );
  } else if ( isset($photo) and $photo ) {
    echo attribute_escape( $photo );
  } else if ( isset($thum) and $thum ) {
    echo $thum;
  } else {
    // echo __('None');
  }
}
add_filter( 'manage_posts_columns', 'manage_posts_columns' );
add_action( 'manage_posts_custom_column', 'add_column', 10, 2 );

/* =============================================
 * JSON API
 * ============================================= */

add_filter('json_api_encode', 'json_api_encode_acf');
function json_api_encode_acf($response) {
  if (isset($response['posts'])) {
    foreach ($response['posts'] as $post) {
      json_api_add_acf($post); // Add specs to each post
    }
  }
  else if (isset($response['post'])) {
    json_api_add_acf($response['post']); // Add a specs property
  }
  else if (isset($response['page'])) {
    json_api_add_acf($response['page']); // Add a specs to a page
  }
  return $response;
}
function json_api_add_acf(&$post) {
  // 余計なキーを削除
  unset( $post->author, $post->comment_count, $post->comment_status, $post->comments, $post->modified, $post->slug );
  // Advanced Custom Posts プラグイン対応
  $post->acf = get_fields($post->id);
  // $post->previous_title = get_fields($post->id);
}

/* =============================================
 * その他
 * ============================================= */

class relative_URI {
  public function __construct() {
    add_action('get_header', array(&$this, 'get_header'), 1);
    add_action('wp_footer', array(&$this, 'wp_footer'), 99999);
  }
  protected function replace_relative_URI($content) {
    $home_url = trailingslashit(get_home_url('/'));
    $top_url = preg_replace( '/^(https?:\/\/.+?)\/(.*)$/', '$1', $home_url );
    return str_replace( $top_url, '', $content );
  }
  public function get_header(){
    ob_start(array(&$this, 'replace_relative_URI'));
  }
  public function wp_footer(){
    ob_end_flush();
  }
}
$relative_URI = new relative_URI();

function new_excerpt_more( $more ) {
  return ''; // …
}
add_filter('excerpt_more', 'new_excerpt_more');

function new_excerpt_length( $length ) {
  return 20;
}
add_filter('excerpt_length', 'new_excerpt_length');

function get_current_url() {
  if ( isset($_SERVER['HTTPS']) and $_SERVER['HTTPS'] == 'on' ) {
    $protocol = 'https://';
  } else {
    $protocol = 'http://';
  }
  return $protocol.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
}
function new_excerpt( $length ) {
  global $post;
  $content = strip_tags($post->post_content);
  $content = preg_replace('/(\n|\r|\s|　|\t)/', '', $content);
  $content = preg_replace('/(，)/', '、', $content);
  $content = preg_replace('/(．)/', '。', $content);
  $content = mb_substr($content, 0, $length);
  return $content;
}
function put_breadcrumbs() {
  /* === OPTIONS === */
  $text['home']     = 'Home'; // text for the 'Home' link
  $text['category'] = 'Archive by Category "%s"'; // text for a category page
  $text['search']   = 'Search Results for "%s" Query'; // text for a search results page
  $text['tag']      = 'Posts Tagged "%s"'; // text for a tag page
  $text['author']   = 'Articles Posted by %s'; // text for an author page
  $text['404']      = 'Error 404'; // text for the 404 page

  $show_current   = 1; // 1 - show current post/page/category title in breadcrumbs, 0 - don't show
  $show_on_home   = 0; // 1 - show breadcrumbs on the homepage, 0 - don't show
  $show_home_link = 1; // 1 - show the 'Home' link, 0 - don't show
  $show_title     = 1; // 1 - show the title for the links, 0 - don't show
  $delimiter      = '<i class="fa fa-angle-right"></i>'; // ' &raquo; '; // delimiter between crumbs
  $before         = '<p class="current">'; // tag before the current crumb
  $after          = '</p>'; // tag after the current crumb
  /* === END OF OPTIONS === */

  global $post;
  $home_link    = home_url('/');
  $link_before  = '<p typeof="v:Breadcrumb">';
  $link_after   = '</p>';
  $link_attr    = ' rel="v:url" property="v:title"';
  $link         = $link_before . '<a' . $link_attr . ' href="%1$s">%2$s</a>' . $link_after;
  $parent_id    = $parent_id_2 = $post->post_parent;
  $frontpage_id = get_option('page_on_front');

  $nav_class    = 'ui-breadcrumbs';

  if (is_home() || is_front_page()) {
    if ($show_on_home == 1) echo '<nav class="'.$nav_class.'"><a href="'.$home_link.'">'.$text['home'].'</a></nav>';

  } else {

    echo '<nav class="'.$nav_class.'" xmlns:v="http://rdf.data-vocabulary.org/#">';
    if ($show_home_link == 1) {
      echo '<a href="'.$home_link.'" rel="v:url" property="v:title">'.$text['home'].'</a>';
      if ($frontpage_id == 0 || $parent_id != $frontpage_id) echo $delimiter;
    }

    if ( is_category() ) {
      $this_cat = get_category(get_query_var('cat'), false);
      if ($this_cat->parent != 0) {
        $cats = get_category_parents($this_cat->parent, TRUE, $delimiter);
        if ($show_current == 0) $cats = preg_replace("#^(.+)$delimiter$#", "$1", $cats);
        $cats = str_replace('<a', $link_before.'<a'.$link_attr, $cats);
        $cats = str_replace('</a>', '</a>'.$link_after, $cats);
        if ($show_title == 0) $cats = preg_replace('/ title="(.*?)"/', '', $cats);
        echo $cats;
      }
      if ($show_current == 1) echo $before.sprintf($text['category'], single_cat_title('', false)).$after;

    } elseif ( is_search() ) {
      echo $before.sprintf($text['search'], get_search_query()).$after;

    } elseif ( is_day() ) {
      echo sprintf($link, get_year_link(get_the_time('Y')), get_the_time('Y')).$delimiter;
      echo sprintf($link, get_month_link(get_the_time('Y'),get_the_time('m')), get_the_time('F')).$delimiter;
      echo $before.get_the_time('d').$after;

    } elseif ( is_month() ) {
      echo sprintf($link, get_year_link(get_the_time('Y')), get_the_time('Y')).$delimiter;
      echo $before.get_the_time('F').$after;

    } elseif ( is_year() ) {
      echo $before.get_the_time('Y').$after;

    } elseif ( is_single() && !is_attachment() ) {
      if ( get_post_type() != 'post' ) {
        $post_type = get_post_type_object(get_post_type());
        $slug = $post_type->rewrite;
        printf($link, $home_link.$slug['slug'].'/', $post_type->labels->singular_name);
        if ($show_current == 1) echo $delimiter.$before.get_the_title().$after;
      } else {
        $cat = get_the_category(); $cat = $cat[0];
        $cats = get_category_parents($cat, TRUE, $delimiter);
        if ($show_current == 0) $cats = preg_replace("#^(.+)$delimiter$#", "$1", $cats);
        $cats = str_replace('<a', $link_before.'<a'.$link_attr, $cats);
        $cats = str_replace('</a>', '</a>'.$link_after, $cats);
        if ($show_title == 0) $cats = preg_replace('/ title="(.*?)"/', '', $cats);
        echo $cats;
        if ($show_current == 1) echo $before.get_the_title().$after;
      }

    } elseif ( !is_single() && !is_page() && get_post_type() != 'post' && !is_404() ) {
      $post_type = get_post_type_object(get_post_type());
      echo $before.$post_type->labels->singular_name.$after;

    } elseif ( is_attachment() ) {
      $parent = get_post($parent_id);
      $cat = get_the_category($parent->ID); $cat = $cat[0];
      $cats = get_category_parents($cat, TRUE, $delimiter);
      $cats = str_replace('<a', $link_before.'<a'.$link_attr, $cats);
      $cats = str_replace('</a>', '</a>'.$link_after, $cats);
      if ($show_title == 0) $cats = preg_replace('/ title="(.*?)"/', '', $cats);
      echo $cats;
      printf($link, get_permalink($parent), $parent->post_title);
      if ($show_current == 1) echo $delimiter.$before.get_the_title().$after;

    } elseif ( is_page() && !$parent_id ) {
      if ($show_current == 1) echo $before.get_the_title().$after;

    } elseif ( is_page() && $parent_id ) {
      if ($parent_id != $frontpage_id) {
        $breadcrumbs = array();
        while ($parent_id) {
          $page = get_page($parent_id);
          if ($parent_id != $frontpage_id) {
            $breadcrumbs[] = sprintf($link, get_permalink($page->ID), get_the_title($page->ID));
          }
          $parent_id = $page->post_parent;
        }
        $breadcrumbs = array_reverse($breadcrumbs);
        for ($i = 0; $i < count($breadcrumbs); $i++) {
          echo $breadcrumbs[$i];
          if ($i != count($breadcrumbs)-1) echo $delimiter;
        }
      }
      if ($show_current == 1) {
        if ($show_home_link == 1 || ($parent_id_2 != 0 && $parent_id_2 != $frontpage_id)) echo $delimiter;
        echo $before.get_the_title().$after;
      }

    } elseif ( is_tag() ) {
      echo $before.sprintf($text['tag'], single_tag_title('', false)).$after;

    } elseif ( is_author() ) {
      global $author;
      $userdata = get_userdata($author);
      echo $before.sprintf($text['author'], $userdata->display_name).$after;

    } elseif ( is_404() ) {
      echo $before.$text['404'].$after;
    }

    if ( get_query_var('paged') ) {
      if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ' (';
      echo __('Page').' '.get_query_var('paged');
      if ( is_category() || is_day() || is_month() || is_year() || is_search() || is_tag() || is_author() ) echo ')';
    }

    echo '</nav>';

  }
}


function toLastUpdateString($target, $now=null) {
  if (!$now) $now = new DateTime('@' . $_SERVER['REQUEST_TIME']);

  /** @type DateInterval $diff */
  $diff = date_diff($target, $now);

  if ($diff->invert) {
    trigger_error('未来');
    return 'たった今';
  }

  if ($diff->y) return $diff->y . '年前';
  if ($diff->m) return $diff->m . 'ヶ月前';
  if ($diff->d) return $diff->d . '日前';
  if ($diff->h) return $diff->h . '時間前';
  if ($diff->i) return $diff->i . '分前';
  if ($diff->s) return $diff->s . '秒前';
  return 'たった今';
}

// 画像サイズを追加
if ( true || function_exists( 'add_image_size' ) ) { // TEMP
  add_image_size( 'project-archive', 640, 404, true );
  add_image_size( 'project-single', 1200, 720, true );

  add_image_size( 'photolog-archive', 344, 344, true );
  add_image_size( 'photolog-single', 1440, 1080, true );

  add_image_size( 'report-archive', 1200, 688, true );
}

// function my_custom_sizes( $sizes ) {
//   return array_merge( $sizes, array(
//     'your-custom-size' => __('Your Custom Size Name'),
//   ) );
// }
// add_filter( 'image_size_names_choose', 'my_custom_sizes' );


/* ----------------------------------------------------- *
 * = ダウンロード(会計ページ)への追加フィールド
 * ----------------------------------------------------- */
function pippin_edd_custom_checkout_fields() {
  ?>
  <p id="edd-company-wrap">
    <label class="edd-label" for="edd-company">
      <?php //_e( 'Company Name', 'edd' ); ?>ご所属（学校名・企業名など）
      <?php if( edd_field_is_required( 'edd_company' ) ) { ?>
        <span class="edd-required-indicator">*</span>
      <?php } ?>
    </label>
    <input class="edd-input required" type="text" name="edd_company" placeholder="<?php //_e('Company name', 'edd'); ?>所属（学校名・企業名など）" id="edd-company" value="" />
  </p>

  <p id="edd-objective-wrap">
    <label class="edd-label" for="edd-objective">
      <?php //_e( 'Objective', 'edd' ); ?>ご使用目的
      <?php if( edd_field_is_required( 'edd_objective' ) ) { ?>
        <span class="edd-required-indicator">*</span>
      <?php } ?>
    </label>
    <textarea class="edd-input required" type="text" name="edd_objective" placeholder="<?php //_e('Objective', 'edd'); ?>ご使用目的" id="edd-objective" value=""></textarea>
  </p>
  <?php
}
add_action('edd_purchase_form_user_info', 'pippin_edd_custom_checkout_fields');
/* ----------------------------------------------------- *
 * = ダウンロード(会計ページ)への追加フィールドのバリデーション
 * ----------------------------------------------------- */
// function pippin_edd_validate_custom_fields($data) {
//   echo $data['edd_company'];
//   if(!isset($data['edd_company']) || $data['edd_company'] == '') {
//     edd_set_error( 'invalid_company', /*__('You must provide your company name.', 'pippin_edd')*/'ご所属（学校名・企業名など）を入力して下さい。' );
//   }
//   if(!isset($data['edd_objective']) || $data['edd_objective'] == '') {
//     edd_set_error( 'invalid_objective', /*__('You must provide your objective.', 'pippin_edd')*/'ご使用目的を入力して下さい。' );
//   }
// }
// add_action('edd_checkout_error_checks', 'pippin_edd_validate_custom_fields');
/* ----------------------------------------------------- *
 * = ダウンロード(会計ページ)への追加フィールドの保存
 * // Store the custom field data in the payment meta
 * ----------------------------------------------------- */
function pippin_edd_store_custom_fields($payment_meta) {
  $payment_meta['company'] = isset($_POST['edd_company']) ? $_POST['edd_company'] : '';
  $payment_meta['objective'] = isset($_POST['edd_objective']) ? $_POST['edd_objective'] : '';
  return $payment_meta;
}
add_filter('edd_payment_meta', 'pippin_edd_store_custom_fields');
/* ----------------------------------------------------- *
 * = ダウンロード(会計ページ)への追加フィールドの確認表示
 * // Displaying the Custom Payment Meta
 * // Show the custom fields in the "View Order Details" popup
 * ----------------------------------------------------- */
function pippin_edd_purchase_details($payment_meta, $user_info) {
  $company = isset($payment_meta['company']) ? $payment_meta['company'] : 'none';
  $objective = isset($payment_meta['objective']) ? $payment_meta['objective'] : 'none';
  ?>
  <div class="column-container">
    <div class="column">
      <strong><?php echo /*__('Company:', 'pippin')*/ '所属（学校名・企業名など）'; ?>:</strong>&nbsp;
      <input type="text" name="edd-payment-company" value="<?php echo $company; ?>" class="medium-text" placeholder="COMPANY NAME">
    </div>
    <div class="column">
      <strong><?php echo /*__('Objective:', 'pippin')*/ '使用目的'; ?>:</strong>&nbsp;
      <input type="text" name="edd-payment-company" value="<?php echo $objective; ?>" class="medium-text" placeholder="OBJECTIVE">
    </div>
  </div>
  <?php
}
add_action('edd_payment_personal_details_list', 'pippin_edd_purchase_details', 10, 2);