# DEPENDENCIES:
# jQuery
# Dust

$ = window.jQuery

# CLASSES
class NotifyMe extends ProductComponent
	constructor: (@element, @productId, @options) ->
		@sku = null

		@generateSelectors
			Title: '.notifyme-title'
			Form: 'form'
			SkuId: '.notifyme-skuid'
			Loading: '.notifyme-loading'
			Success: '.notifyme-success'
			Error: '.notifyme-error'

		@history = {}

		@init()

	POST_URL: '/no-cache/AviseMe.aspx'

	init: =>
		@render()
		@bindEvents()

	render: =>
		dust.render 'notify-me', @options, (err, out) =>
			throw new Error("Notify Me Dust error: #{err}") if err
			@element.html out

	bindEvents: =>
		@bindProductEvent 'vtex.sku.selected', @skuSelected
		@bindProductEvent 'vtex.sku.unselected', @skuUnselected
		@element.on 'submit', @submit if @options.ajax

	skuSelected: (evt, productId, sku) =>
		@sku = sku
		@hideAll()
		if not @sku.available
			@showTitle()

			switch @history[@sku.sku]
				when 'success' then @showSuccess()
				else
					@findSkuId().val(@sku.sku)
					@showForm()

	skuUnselected: (evt, productId, skus) =>
		@sku = null
		@hideAll()
		
	submit: (evt) =>
		evt.preventDefault()

		@hideForm()
		@showLoading()

		xhr = $.post(@POST_URL, $(evt.target).serialize())
		.always(=> @hideLoading())
		.done(=> @showSuccess(); @history[@sku.sku] = 'success')
		.fail(=> @showError(); @history[@sku.sku] = 'fail')

		@triggerProductEvent 'vtex.notifyMe.submitted', @sku, xhr

		return false

	hideAll: =>
		@hideTitle()
		@hideForm()
		@hideLoading()
		@hideSuccess()
		@hideError()


# PLUGIN ENTRY POINT
$.fn.notifyMe = (productId, jsOptions) ->
	defaultOptions = $.extend {}, $.fn.notifyMe.defaults
	for element in this
		$element = $(element)
		domOptions = $element.data()
		options = $.extend(true, defaultOptions, domOptions, jsOptions)
		unless $element.data('notifyMe')
			$element.data('notifyMe', new NotifyMe($element, productId, options))

	return this


# PLUGIN DEFAULTS
$.fn.notifyMe.defaults =
	ajax: true
	strings:
		title: ''
		explanation: 'Para ser avisado da disponibilidade deste Produto, basta preencher os campos abaixo.'
		namePlaceholder: 'Digite seu nome...'
		emailPlaceholder: 'Digite seu e-mail...'
		loading: 'Carregando...'
		success: 'Cadastrado com sucesso. Assim que o produto for disponibilizado você receberá um email avisando.'
		error: 'Não foi possível cadastrar. Tente mais tarde.'
