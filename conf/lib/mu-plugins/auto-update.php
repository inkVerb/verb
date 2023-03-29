<?php
/**
 * @version 1.0
 */
/*
Plugin Name: inkVerb Auto-Update
Plugin URI: http://verb.ink/
Description: This auto-updates core, plugins, and themes. It has been added via the inkVerb control interface.
Author: inkVerb
Version: 1.0
Author URI: http://verb.ink/
*/
/*
Credits and information pages
https://codex.wordpress.org/Must_Use_Plugins
https://codex.wordpress.org/Configuring_Automatic_Background_Updates
*/


// ** Auto Updates - added by inkVerb  ** //
// These are added individually, for the main types of auto-updates. They are self-descriptive.
define( 'WP_AUTO_UPDATE_CORE', true );
add_filter( 'auto_update_plugin', '__return_true' );
add_filter( 'auto_update_theme', '__return_true' );

?>
