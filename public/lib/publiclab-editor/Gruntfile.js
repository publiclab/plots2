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
                    'src/PublicLab.Editor.js'
                ],
                dest: 'dist/PublicLab.Editor.js'
            }
        },

        jasmine: {
          publiclabeditor: {
            src: 'dist/*.js',
            options: {
              specs: 'spec/javascripts/*spec.js',
              vendor: [
                'node_modules/jquery/dist/jquery.min.js',
                'node_modules/bootstrap/dist/js/bootstrap.min.js',
                'node_modules/blueimp-file-upload/js/vendor/jquery.ui.widget.js',
                'node_modules/blueimp-file-upload/js/jquery.iframe-transport.js',
                'node_modules/blueimp-file-upload/js/jquery.fileupload.js',
                'node_modules/typeahead.js/dist/typeahead.jquery.js',
                'node_modules/typeahead.js/dist/bloodhound.js',
                'node_modules/bootstrap-tokenfield/dist/bootstrap-tokenfield.js',
                'node_modules/jasmine-jquery/lib/jasmine-jquery.js',
                'node_modules/jasmine-ajax/lib/mock-ajax.js'
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
