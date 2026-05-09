;; extends

; Route object keys in TanStack Router definitions
((pair
   key: (property_identifier) @route.key)
  (#any-of? @route.key "validateSearch" "beforeLoad" "component"))

; createFileRoute(...) call
((call_expression
   function: (identifier) @route.key)
  (#eq? @route.key "createFileRoute"))

; Specific calls that should be blue
((call_expression
   function: (identifier) @route.call)
  (#any-of? @route.call "getItem" "redirect"))

((call_expression
   function: (member_expression
     property: (property_identifier) @route.call))
  (#any-of? @route.call "isAuthenticated" "includes"))
