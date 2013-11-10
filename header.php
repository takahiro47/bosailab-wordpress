<?php
/**
 * The Header for our theme.
 *
 * Displays all of the <head> section and everything up till <div id="main">
 *
 * @package WordPress
 * @subpackage SFC_Bosalab_2013
 * @since 1.0
 */
?><!DOCTYPE html>
<!--[if IE 7]>
<html class="ie ie7" <?php language_attributes(); ?>>
<![endif]-->
<!--[if IE 8]>
<html class="ie ie8" <?php language_attributes(); ?>>
<![endif]-->
<!--[if !(IE 7) | !(IE 8)  ]><!-->
<html <?php language_attributes(); ?>>
<!--<![endif]-->
<head>
  <meta charset="<?php bloginfo( 'charset' ); ?>">
  <meta name="viewport" content="width=device-width">
  <title><?php wp_title( '|', true, 'right' ); ?></title>
  <link rel="profile" href="http://gmpg.org/xfn/11">
  <link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>">
  <!--[if lt IE 9]>
    <script src="<?php echo get_template_directory_uri(); ?>/js/html5.js"></script>
  <![endif]-->
  <?php wp_head(); ?>
  <?php /*
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  */ ?>
</head>

<body <?php body_class(); ?>>
  <div id="page" class="hfeed site">
    <header id="masthead" class="site-header" role="banner">
      <?php /*
      <div id="navbar" class="navbar">
        <nav id="site-navigation" class="navigation main-navigation" role="navigation">
          <h3 class="menu-toggle"><?php _e( 'Menu', 'twentythirteen' ); ?></h3>
          <a class="screen-reader-text skip-link" href="#content" title="<?php esc_attr_e( 'Skip to content', 'twentythirteen' ); ?>"><?php _e( 'Skip to content', 'twentythirteen' ); ?></a>
          <?php wp_nav_menu( array( 'theme_location' => 'primary', 'menu_class' => 'nav-menu' ) ); ?>
          <?php get_search_form(); ?>
        </nav><!-- #site-navigation -->
      </div><!-- #navbar -->

      <i class="fa fa-angle-double-down"></i>
      */ ?>

     <div id="navbar" class="navbar">
        <nav id="site-navigation" class="navigation main-navigation" role="navigation">
          <h3 class="menu-toggle"><?php _e( 'Menu', 'twentythirteen' ); ?></h3>
          <a class="screen-reader-text skip-link" href="#content" title="<?php esc_attr_e( 'Skip to content', 'twentythirteen' ); ?>"><?php _e( 'Skip to content', 'twentythirteen' ); ?></a>
          <?php wp_nav_menu( array( 'theme_location' => 'primary', 'menu_class' => 'nav-menu' ) ); ?>
          <?php get_search_form(); ?>
        </nav><!-- #site-navigation -->
      </div><!-- #navbar -->

      <a class="home-link" href="<?php echo esc_url( home_url( '/' ) ); ?>" title="<?php echo esc_attr( get_bloginfo( 'name', 'display' ) ); ?>" rel="home">
        <h1 class="site-title"><?php bloginfo( 'name' ); ?></h1>
        <h2 class="site-description"><?php bloginfo( 'description' ); ?></h2>
      </a>

      <?php /*
      <a class="home-link" href="<?php echo esc_url( home_url( '/' ) ); ?>" title="<?php echo esc_attr( get_bloginfo( 'name', 'display' ) ); ?>" rel="home">
        <h1 class="site-title"><?php bloginfo( 'name' ); ?></h1>
        <h2 class="site-description"><?php bloginfo( 'description' ); ?></h2>
      </a>
      */ ?>

    </header><!-- #masthead -->

    <div id="main" class="site-main">

      <div id="header-publicities">
        <div class="publicity-aritcle">
        </div>
        <div class="publicity-items">
        </div>
      </div>


