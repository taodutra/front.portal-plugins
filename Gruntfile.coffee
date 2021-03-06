module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	replacements =
		'VERSION': pkg.version

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean:
			main: ['build', 'tmp-deploy']

		copy:
			main:
				expand: true
				cwd: 'src/'
				src: ['**', '!coffee/**', '!**/*.less']
				dest: 'build/<%= relativePath %>'
			mocks:
				src: ['spec/mocks/*.json']
				dest: 'build/<%= relativePath %>/'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build/<%= relativePath %>/js/'
					ext: '.js'
				]

		concat:
			dev:
				files:
					'build/js/portal-sku-selector-with-template.js': ['build/js/product-component.js', 'build/templates/template-sku-selector-modal.js', 'build/templates/template-sku-selector-product.js', 'build/js/portal-sku-selector.js']
					'build/js/portal-quantity-selector-with-template.js': ['build/js/product-component.js', 'build/templates/template-quantity-selector.js', 'build/js/portal-quantity-selector.js']
					'build/js/portal-accessories-selector-with-template.js': ['build/js/product-component.js', 'build/templates/template-accessories-selector.js', 'build/js/portal-accessories-selector.js']
					'build/js/portal-price-with-template.js': ['build/js/product-component.js', 'build/templates/template-price.js', 'build/js/portal-price.js']
					'build/js/portal-buy-button.js': ['build/js/product-component.js', 'build/js/portal-buy-button.js']
					'build/js/portal-notify-me-with-template.js': ['build/js/product-component.js', 'build/templates/template-notify-me.js', 'build/js/portal-notify-me.js']
					'build/js/portal-minicart-with-template.js': ['build/js/product-component.js', 'build/templates/template-minicart.js', 'build/js/portal-minicart.js']
					'build/js/portal-sku-measures-with-template.js': ['build/js/product-component.js', 'build/templates/template-sku-measures.js', 'build/js/portal-sku-measures.js']

		uglify:
			mangle:
				except: ['$', '_']
			main:
				files:
					'build/js/portal-template-as-modal.min.js': ['build/js/portal-template-as-modal.js']
					'build/js/portal-sku-selector-with-template.min.js': ['build/js/portal-sku-selector-with-template.js']
					'build/js/portal-quantity-selector-with-template.min.js': ['build/js/portal-quantity-selector-with-template.js']
					'build/js/portal-accessories-selector-with-template.min.js': ['build/js/portal-accessories-selector-with-template.js']
					'build/js/portal-price-with-template.min.js': ['build/js/portal-price-with-template.js']
					'build/js/portal-buy-button.min.js': ['build/js/portal-buy-button.js']
					'build/js/portal-notify-me-with-template.min.js': ['build/js/portal-notify-me-with-template.js']
					'build/js/portal-minicart-with-template.min.js': ['build/js/portal-minicart-with-template.js']
					'build/js/portal-sku-measures-with-template.min.js': ['build/js/portal-sku-measures-with-template.js']

		karma:
			options:
				configFile: 'karma.conf.coffee'
			unit:
				background: true
			single:
				singleRun: true

		dustjs:
			compile:
				files:
					'build/templates/template-sku-selector-modal.js': 'src/templates/sku-selector-modal.dust'
					'build/templates/template-sku-selector-product.js': 'src/templates/sku-selector-product.dust'
					'build/templates/template-quantity-selector.js': 'src/templates/quantity-selector.dust'
					'build/templates/template-accessories-selector.js': 'src/templates/accessories-selector.dust'
					'build/templates/template-price.js': 'src/templates/price.dust'
					'build/templates/template-notify-me.js': 'src/templates/notify-me.dust'
					'build/templates/template-minicart.js': 'src/templates/minicart.dust'
					'build/templates/template-sku-measures.js': 'src/templates/sku-measures.dust'

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.dust', 'src/**/*.coffee', 'spec/**/*.coffee', 'spec/**/*.html', 'src/**/*.js', 'src/**/*.less']
				tasks: ['clean', 'concurrent:transform', 'concat', 'uglify']

		concurrent:
			transform: ['copy:main', 'copy:mocks', 'coffee', 'dustjs']

		vtex_deploy:
			main:
				options:
					buildDirectory: 'build'
			dry:
				options:
					buildDirectory: 'build'
					requireEnvironmentType: 'dryrun'
					dryRun: true
			walmart:
				options:
					buildDirectory: 'build'
					bucket: 'vtex-io-walmart'
					requireEnvironmentType: 'stable'

	grunt.loadNpmTasks name for name of pkg.dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'concat', 'uglify', 'server', 'watch:main']
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'concat', 'uglify'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']