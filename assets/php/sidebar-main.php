<?php
/**
 * The sidebar containing the footer widget area.
 *
 * If no active widgets in this sidebar, it will be hidden completely.
 *
 * @package WordPress
 * @subpackage SFC_Bosalab_2013
 * @since 1.0
 */

if ( is_active_sidebar( 'sidebar-1' ) ) : ?>
  <div id="secondary" class="sidebar-container" role="complementary">
    <div class="widget-area">
      <?php dynamic_sidebar( 'sidebar-1' ); ?>
    </div><!-- .widget-area -->
  </div><!-- #secondary -->
<?php endif; ?>