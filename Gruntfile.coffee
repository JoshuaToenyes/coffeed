module.exports = (grunt) ->

  config =

    pkg: (grunt.file.readJSON('package.json'))

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      options:
        sourceMap: true
      app:
        expand: true,
        flatten: false,
        cwd: 'src',
        src: ['**/*.coffee'],
        dest: 'dist',
        ext: '.js'
      test:
        expand: true,
        flatten: false,
        cwd: 'test',
        src: ['./**/*.coffee'],
        dest: 'test',
        ext: '.js'

    file_append:
      default_options:
        files:
          'dist/cli.js':
            prepend: '#! /usr/bin/env node\n'
            input: 'dist/cli.js'

    chmod:
      options:
        mode: '770'
      critiqa:
        src: 'dist/cli.js'

    watch:
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['compile']
      configFiles:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    clean:
      all: ['dist/*', 'test/**/*.js']

    replace:
      version:
        src: ['dist/coffeed'],
        overwrite: true,
        replacements: [{
          from: "*|VERSION|*",
          to: "<%= pkg.version %>"
        }]

    mochaTest:
      test:
        src: ['test/**/*.js']


  grunt.initConfig(config)
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-file-append')
  grunt.loadNpmTasks('grunt-chmod')
  grunt.loadNpmTasks('grunt-text-replace')

  grunt.registerTask('vagrant', ['copy'])

  grunt.registerTask('compile', [
    'coffeelint',
    'clean',
    'coffee',
    'file_append',
    'replace:version',
    'chmod']);

  grunt.registerTask('test', ['compile', 'mochaTest']);
