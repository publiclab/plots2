module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: ';'
      },
      dist: {
        src: ['bower_components/Blob.js/Blob.js', 'bower_components/FileSaver/FileSaver.js', 'ics.js'],
        dest: 'ics.deps.min.js'
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today() %> */\n'
      },
      dist: {
        files: {
          'ics.min.js': ['ics.js'],
          'ics.deps.min.js': ['ics.deps.min.js'] 
        }
      }
    },
    mocha: {
        all: {
            src: ['test/index.html'],
            options: {
                run: true,
                log: true
                // urls: ['http://<%= connect.test.options.hostname %>:<%= connect.test.options.port %>/index.html']
            }
        }
    },
    jshint: {
      files: ['Gruntfile.js', 'ics.js', 'test/spec/test.js'],
      options: {
        // options here to override JSHint defaults
        globals: {
          jQuery: true,
          console: true,
          module: true,
          document: true,
        },
        laxcomma: true
      }
    },
    watch: {
      files: ['<%= jshint.files %>'],
      tasks: ['jshint', 'mocha']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-mocha');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');

  grunt.registerTask('test', ['jshint', 'mocha']);

  grunt.registerTask('default', ['jshint', 'mocha', 'concat', 'uglify']);

};