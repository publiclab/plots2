module.exports = function(grunt) {

    grunt.loadNpmTasks('grunt-browserify');

    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({

      pkg: grunt.file.readJSON('package.json'),

      watch: {
          options : {
              livereload: true
          },
          source: {
              files: [
                  'src/*.js',
                  'src/*/*.js',
                  'Gruntfile.js'
              ],
              tasks: [ 'build:js' ]
          }
      },

      browserify: {
          dist: {
              src: [
                  'src/inlineMarkdownEditor.js'
              ],
              dest: 'dist/inlineMarkdownEditor.js'
          }
      },

      jasmine: {
        inlineMarkdownEditor: {
          src: 'dist/*.js',
          options: {
            specs: 'spec/javascripts/*spec.js',
            vendor: [
              'node_modules/jquery/dist/jquery.min.js',
              'node_modules/jasmine-jquery/lib/jasmine-jquery.js',
              'node_modules/jasmine-ajax/lib/mock-ajax.js',
              'node_modules/bootstrap/dist/js/bootstrap.min.js'
            ]
          }
        }
      }

    });

    /* Default (development): Watch files and build on change. */
    grunt.registerTask('default', ['watch']);

    grunt.registerTask('build', [
        'browserify:dist'
    ]);

    grunt.loadNpmTasks('grunt-contrib-jasmine');

};
