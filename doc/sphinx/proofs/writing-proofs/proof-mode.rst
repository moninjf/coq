.. _proofhandling:

----------
Proof mode
----------

:gdef:`Proof mode <proof mode>` is used to prove theorems.
Coq enters proof mode when you begin a proof,
such as with the :cmd:`Theorem` command.  It exits proof mode when
you complete a proof, such as with the :cmd:`Qed` command.  Tactics,
which are available only in proof mode, incrementally transform incomplete
proofs to eventually generate a complete proof.

When you run Coq interactively, such as through CoqIDE, Proof General or
coqtop, Coq shows the current proof state (the incomplete proof) as you
enter tactics.  This information isn't shown when you run Coq in batch
mode with `coqc`.

Proof State
-----------

The :gdef:`proof state` consists of one or more unproven goals.
Each goal has a :gdef:`conclusion` (the statement that is to be proven)
and a :gdef:`local context`, which contains named :term:`hypotheses <hypothesis>`
(which are propositions), variables and local definitions that can be used in
proving the conclusion.  The proof may also use *constants* from the :term:`global environment`
such as definitions and proven theorems.

(Note that *conclusion* is also used to refer to the last part of an implication.
For example, in `A -> B -> C`, `A` and `B` are :term:`premises <premise>` and `C`
is the conclusion.)

The term ":gdef:`goal`" may refer to an entire goal or to the conclusion
of a goal, depending on the context.

The conclusion appears below a line and the local context appears above the line.
The conclusion is a type.  Each item in the local context begins with a name
and ends, after a colon, with an associated type.
Local definitions are shown in the form `n := 0 : nat`, for example, in which `nat` is the
type of `0`.

The local context of a goal contains items specific to the goal as well
as section-local variables and hypotheses (see :ref:`gallina-assumptions`) defined
in the current :ref:`section <section-mechanism>`.  The latter are included in the
initial proof state.
Items in the local context are ordered; an item can only refer to items that appear
before it.  (A more mathematical description of the *local context* is
:ref:`here <Local-context>`.)

The :gdef:`global environment` has definitions and proven theorems that are global in scope.
(A more mathematical description of the *global environment* is :ref:`here <Global-environment>`.)

When you begin proving a theorem, the proof state shows
the statement of the theorem below the line and often nothing in the
local context:

.. coqtop:: none

   Parameter P: nat -> Prop.

.. coqtop:: out

   Goal forall n m: nat, n > m -> P 1 /\ P 2.

After applying the :tacn:`intros` :term:`tactic`, we see hypotheses above the line.
The names of variables (`n` and `m`) and hypotheses (`H`) appear before a colon, followed by
the type they represent.

.. coqtop:: all

   intros.

Some tactics, such as :tacn:`split`, create new goals, which may
be referred to as :gdef:`subgoals <subgoal>` for clarity.
Goals are numbered from 1 to N at each step of the proof to permit applying a
tactic to specific goals.  The local context is only shown for the first goal.

.. coqtop:: all

   split.

"Variables" may refer specifically to local context items for which the type of their type
is `Set` or `Type`, and :gdef:`"hypotheses" <hypothesis>` refers to items that are
:term:`propositions <proposition>`,
for which the type of their type is `Prop` or `SProp`,
but these terms are also used interchangeably.

.. coqtop:: out

   let t_n := type of n in idtac "type of n :" t_n;
   let tt_n := type of t_n in idtac "type of" t_n ":" tt_n.
   let t_H := type of H in idtac "type of H :" t_H;
   let tt_H := type of t_H in idtac "type of" t_H ":" tt_H.

A proof script, consisting of the tactics that are applied to prove a
theorem, is often informally referred to as a "proof".
The real proof, whether complete or incomplete, is a term, the :gdef:`proof term`,
which users may occasionally want to examine.  (This is based on the
*Curry-Howard isomorphism* :cite:`How80,Bar81,Gir89,H89`, which is
a correspondence between between proofs and terms and between
propositions and types of λ-calculus.  The isomorphism is also
sometimes called the "propositions-as-types correspondence".)

The :cmd:`Show Proof` command displays the incomplete proof term
before you've completed the proof.  For example, here's the proof
term after using the :tacn:`split` tactic above:

.. coqtop:: all

   Show Proof.

The incomplete parts, the goals, are represented by
:term:`existential variables <existential variable>`
with names that begin with `?Goal`.  The :cmd:`Show Existentials` command
shows each existential with the hypotheses and conclusion for the associated goal.

.. coqtop:: all

   Show Existentials.

Coq's kernel verifies the correctness of proof terms when it exits
proof mode by checking that the proof term is :term:`well-typed` and
that its type is the same as the theorem statement.

After a proof is completed, :cmd:`Print` `<theorem_name>`
shows the proof term and its type.  The type appears after
the colon (`forall ...`), as for this theorem from Coq's standard library:

.. coqtop:: all

   Print proj1.

.. _proof-editing-mode:

Entering and exiting proof mode
-------------------------------

Coq enters :term:`proof mode` when you begin a proof through
commands such as :cmd:`Theorem` or :cmd:`Goal`.  Coq user interfaces
usually have a way to indicate that you're in proof mode.

:term:`Tactics <tactic>` are available only in proof mode (currently they give syntax
errors outside of proof mode).  Most :term:`commands <command>` can be used both in and out of
proof mode, but some commands only work in or outside of proof mode.

When the proof is completed, you can exit proof mode with commands such as
:cmd:`Qed`, :cmd:`Defined` and :cmd:`Save`.

.. cmd:: Goal @type

   Asserts an unnamed proposition.  This is intended for quick tests that
   a proposition is provable.  If the proof is eventually completed and
   validated, you can assign a name with the :cmd:`Save` or :cmd:`Defined`
   commands.  If no name is given, the name will be `Unnamed_thm` (or,
   if that name is already defined, a variant of that).

.. cmd:: Qed

   Passes a completed :term:`proof term` to Coq's kernel
   to check that the proof term is :term:`well-typed` and
   to verify that its type matches the theorem statement.  If it's verified, the
   proof term is added to the global environment as an :term:`opaque` constant
   using the declared name from the original goal.

   It's very rare for a proof term to fail verification.  Generally this
   indicates a bug in a tactic you used or that you misused some
   unsafe tactics.

   .. exn:: Attempt to save an incomplete proof.
      :undocumented:

   .. exn:: No focused proof (No proof-editing in progress).

      You tried to use a proof mode command such as :cmd:`Qed` outside of proof
      mode.

   .. note::

      Sometimes an error occurs when building the proof term, because
      tactics do not enforce completely the term construction
      constraints.

      The user should also be aware of the fact that since the
      proof term is completely rechecked at this point, one may have to wait
      a while when the proof is large. In some exceptional cases one may
      even incur a memory overflow.

.. cmd:: Save @ident

   Similar to :cmd:`Qed`, except that the proof term is added to the global
   context with the name :token:`ident`, which
   overrides any name provided by the :cmd:`Theorem` command or
   its variants.

.. cmd:: Defined {? @ident }

   Similar to :cmd:`Qed` and :cmd:`Save`, except the proof is made
   :term:`transparent`, which means
   that its content can be explicitly used for type checking and that it can be
   unfolded in conversion tactics (see :ref:`applyingconversionrules`,
   :cmd:`Opaque`, :cmd:`Transparent`).  If :token:`ident` is specified,
   the proof is defined with the given name, which overrides any name
   provided by the :cmd:`Theorem` command or its variants.

.. cmd:: Admitted

   This command is available in proof mode to give up
   the current proof and declare the initial goal as an axiom.

.. cmd:: Abort {? {| All | @ident } }

   Cancels the current proof development, switching back to
   the previous proof development, or to the Coq toplevel if no other
   proof was being edited.

   :n:`@ident`
     Aborts editing the proof named :n:`@ident` for use when you have
     nested proofs.  See also :flag:`Nested Proofs Allowed`.

   :n:`All`
     Aborts all current proofs.

   .. exn:: No focused proof (No proof-editing in progress).
      :undocumented:

.. cmd:: Proof @term
   :name: Proof `term`

   This command applies in proof mode. It is equivalent to
   :n:`exact @term. Qed.`
   That is, you have to give the full proof in one gulp, as a
   proof term (see Section :ref:`applyingtheorems`).

   .. warning::

      Use of this command is discouraged.  In particular, it
      doesn't work in Proof General because it must
      immediately follow the command that opened proof mode, but
      Proof General inserts :cmd:`Unset` :flag:`Silent` before it (see
      `Proof General issue #498
      <https://github.com/ProofGeneral/PG/issues/498>`_).

.. cmd:: Proof

   Is a no-op which is useful to delimit the sequence of tactic commands
   which start a proof, after a :cmd:`Theorem` command. It is a good practice to
   use :cmd:`Proof` as an opening parenthesis, closed in the script with a
   closing :cmd:`Qed`.

   .. seealso:: :cmd:`Proof with`

.. cmd:: Proof using @section_var_expr {? with @ltac_expr }

   .. insertprodn section_var_expr starred_ident_ref

   .. prodn::
      section_var_expr ::= {* @starred_ident_ref }
      | {? - } @section_var_expr50
      section_var_expr50 ::= @section_var_expr0 - @section_var_expr0
      | @section_var_expr0 + @section_var_expr0
      | @section_var_expr0
      section_var_expr0 ::= @starred_ident_ref
      | ( @section_var_expr ) {? * }
      starred_ident_ref ::= @ident {? * }
      | Type {? * }
      | All

   Opens proof mode, declaring the set of
   section variables (see :ref:`gallina-assumptions`) used by the proof.
   At :cmd:`Qed` time, the
   system verifies that the set of section variables used in
   the proof is a subset of the declared one.

   The set of declared variables is closed under type dependency. For
   example, if ``T`` is a variable and ``a`` is a variable of type
   ``T``, then the commands ``Proof using a`` and ``Proof using T a``
   are equivalent.

   The set of declared variables always includes the variables used by
   the statement. In other words ``Proof using e`` is equivalent to
   ``Proof using Type + e`` for any declaration expression ``e``.

   :n:`- @section_var_expr50`
     Use all section variables except those specified by :n:`@section_var_expr50`

   :n:`@section_var_expr0 + @section_var_expr0`
     Use section variables from the union of both collections.
     See :ref:`nameaset` to see how to form a named collection.

   :n:`@section_var_expr0 - @section_var_expr0`
     Use section variables which are in the first collection but not in the
     second one.

   :n:`{? * }`
     Use the transitive closure of the specified collection.

   :n:`Type`
     Use only section variables occurring in the statement.  Specifying :n:`*`
     uses the forward transitive closure of all the section variables occurring
     in the statement. For example, if the variable ``H`` has type ``p < 5`` then
     ``H`` is in ``p*`` since ``p`` occurs in the type of ``H``.

   :n:`All`
     Use all section variables.

   .. seealso:: :ref:`tactics-implicit-automation`

.. attr:: using

   This :term:`attribute` can be applied to the :cmd:`Definition`, :cmd:`Example`,
   :cmd:`Fixpoint` and :cmd:`CoFixpoint` commands as well as to :cmd:`Lemma` and
   its variants.  It takes
   a :n:`@section_var_expr`, in quotes, as its value. This is equivalent to
   specifying the same :n:`@section_var_expr` in
   :cmd:`Proof using`.

   .. example::

      .. coqtop:: all reset

         Section Test.
         Variable n : nat.
         Hypothesis Hn : n <> 0.

         #[using="Hn"]
         Lemma example : 0 < n.

      .. coqtop:: in

         Abort.
         End Test.


Proof using options
```````````````````

The following options modify the behavior of ``Proof using``.


.. opt:: Default Proof Using "@section_var_expr"

   Set this :term:`option` to use :n:`@section_var_expr` as the
   default ``Proof using`` value. E.g. ``Set Default Proof Using "a
   b"`` will complete all ``Proof`` commands not followed by a
   ``using`` part with ``using a b``.


.. flag:: Suggest Proof Using

   When this :term:`flag` is on, :cmd:`Qed` suggests
   a ``using`` annotation if the user did not provide one.

..  _`nameaset`:

Name a set of section hypotheses for ``Proof using``
````````````````````````````````````````````````````

.. cmd:: Collection @ident := @section_var_expr

   This can be used to name a set of section
   hypotheses, with the purpose of making ``Proof using`` annotations more
   compact.

   .. example::

      Define the collection named ``Some`` containing ``x``, ``y`` and ``z``::

         Collection Some := x y z.

      Define the collection named ``Fewer`` containing only ``x`` and ``y``::

         Collection Fewer := Some - z

      Define the collection named ``Many`` containing the set union or set
      difference of ``Fewer`` and ``Some``::

         Collection Many := Fewer + Some
         Collection Many := Fewer - Some

      Define the collection named ``Many`` containing the set difference of
      ``Fewer`` and the unnamed collection ``x y``::

         Collection Many := Fewer - (x y)

Proof modes
-----------

When entering proof mode through commands such as :cmd:`Goal` and :cmd:`Proof`,
Coq picks by default the |Ltac| mode. Nonetheless, there exist other proof modes
shipped in the standard Coq installation, and furthermore some plugins define
their own proof modes. The default proof mode used when opening a proof can
be changed using the following option.

.. opt:: Default Proof Mode @string

   This :term:`option` selects the proof mode to use when starting a proof. Depending on the proof
   mode, various syntactic constructs are allowed when writing a
   proof. All proof modes support commands; the proof mode determines
   which tactic language and set of tactic definitions are available.  The
   possible option values are:

   `"Classic"`
     Activates the |Ltac| language and the tactics with the syntax documented
     in this manual.
     Some tactics are not available until the associated plugin is loaded,
     such as `SSR` or `micromega`.
     This proof mode is set when the :term:`prelude` is loaded.

   `"Noedit"`
     No tactic
     language is activated at all. This is the default when the :term:`prelude`
     is not loaded, e.g. through the `-noinit` option for `coqc`.

   `"Ltac2"`
     Activates the Ltac2 language and the Ltac2-specific variants of the documented
     tactics.
     This value is only available after :cmd:`Requiring <Require>` Ltac2.
     :cmd:`Importing <Import>` Ltac2 sets this mode.

   Some external plugins also define their own proof mode, which can be
   activated with this command.

Navigation in the proof tree
--------------------------------

.. cmd:: Undo {? {? To } @natural }

   Cancels the effect of the last :token:`natural` commands or tactics.
   The :n:`To @natural` form goes back to the specified state number.
   If :token:`natural` is not specified, the command goes back one command or tactic.

.. cmd:: Restart

   Restores the proof to the original goal.

   .. exn:: No focused proof to restart.
      :undocumented:

.. cmd:: Focus {? @natural }

   Focuses the attention on the first goal to prove or, if :token:`natural` is
   specified, the :token:`natural`\-th.  The
   printing of the other goals is suspended until the focused goal
   is solved or unfocused.

   .. deprecated:: 8.8

      Prefer the use of bullets or focusing brackets with a goal selector (see below).

.. cmd:: Unfocus

   This command restores to focus the goal that were suspended by the
   last :cmd:`Focus` command.

   .. deprecated:: 8.8

.. cmd:: Unfocused

   Succeeds if the proof is fully unfocused, fails if there are some
   goals out of focus.

.. _curly-braces:

.. tacn:: {? {| @natural | [ @ident ] } : } %{
          %}
   :name: {; }

   .. todo
      See https://github.com/coq/coq/issues/12004 and
      https://github.com/coq/coq/issues/12825.

   ``{`` (without a terminating period) focuses on the first
   goal.  The subproof can only be
   unfocused when it has been fully solved (*i.e.*, when there is no
   focused goal left). Unfocusing is then handled by ``}`` (again, without a
   terminating period). See also an example in the next section.

   Note that when a focused goal is proved a message is displayed
   together with a suggestion about the right bullet or ``}`` to unfocus it
   or focus the next one.

   :n:`@natural:`
     Focuses on the :token:`natural`\-th goal to prove.

   :n:`[ @ident ]: %{`
     Focuses on the named goal :token:`ident`.

   .. note::

      Goals are just existential variables and existential variables do not
      get a name by default. You can give a name to a goal by using :n:`refine ?[@ident]`.
      You may also wrap this in an Ltac-definition like:

      .. coqtop:: in

         Ltac name_goal name := refine ?[name].

   .. seealso:: :ref:`existential-variables`

   .. example::

      This first example uses the Ltac definition above, and the named goals
      only serve for documentation.

      .. coqtop:: all

         Goal forall n, n + 0 = n.
         Proof.
         induction n; [ name_goal base | name_goal step ].
         [base]: {

      .. coqtop:: all

         reflexivity.

      .. coqtop:: in

         }

      .. coqtop:: all

         [step]: {

      .. coqtop:: all

         simpl.
         f_equal.
         assumption.
         }
         Qed.

      This can also be a way of focusing on a shelved goal, for instance:

      .. coqtop:: all

         Goal exists n : nat, n = n.
         eexists ?[x].
         reflexivity.
         [x]: exact 0.
         Qed.

   .. exn:: This proof is focused, but cannot be unfocused this way.

      You are trying to use ``}`` but the current subproof has not been fully solved.

   .. exn:: No such goal (@natural).
      :undocumented:

   .. exn:: No such goal (@ident).
      :undocumented:

   .. exn:: Brackets do not support multi-goal selectors.

      Brackets are used to focus on a single goal given either by its position
      or by its name if it has one.

   .. seealso:: The error messages for bullets below.

.. _bullets:

Bullets
```````

Alternatively, proofs can be structured with bullets instead of ``{`` and ``}``. The
use of a bullet ``b`` for the first time focuses on the first goal ``g``, the
same bullet cannot be used again until the proof of ``g`` is completed,
then it is mandatory to focus the next goal with ``b``. The consequence is
that ``g`` and all goals present when ``g`` was focused are focused with the
same bullet ``b``. See the example below.

Different bullets can be used to nest levels. The scope of bullet does
not go beyond enclosing ``{`` and ``}``, so bullets can be reused as further
nesting levels provided they are delimited by these. Bullets are made of
repeated ``-``, ``+`` or ``*`` symbols:

.. prodn:: bullet ::= {| {+ - } | {+ + } | {+ * } }

Note again that when a focused goal is proved a message is displayed
together with a suggestion about the right bullet or ``}`` to unfocus it
or focus the next one.

.. note::

   In Proof General (``Emacs`` interface to Coq), you must use
   bullets with the priority ordering shown above to have a correct
   indentation. For example ``-`` must be the outer bullet and ``**`` the inner
   one in the example below.

The following example script illustrates all these features:

.. example::

  .. coqtop:: all

    Goal (((True /\ True) /\ True) /\ True) /\ True.
    Proof.
    split.
    - split.
    + split.
    ** { split.
    - trivial.
    - trivial.
    }
    ** trivial.
    + trivial.
    - assert True.
    { trivial. }
    assumption.
    Qed.

.. exn:: Wrong bullet @bullet__1: Current bullet @bullet__2 is not finished.

   Before using bullet :n:`@bullet__1` again, you should first finish proving
   the current focused goal.
   Note that :n:`@bullet__1` and :n:`@bullet__2` may be the same.

.. exn:: Wrong bullet @bullet__1: Bullet @bullet__2 is mandatory here.

   You must put :n:`@bullet__2` to focus on the next goal. No other bullet is
   allowed here.

.. exn:: No such goal. Focus next goal with bullet @bullet.

   You tried to apply a tactic but no goals were under focus.
   Using :n:`@bullet` is  mandatory here.

.. FIXME: the :noindex: below works around a Sphinx issue.
   (https://github.com/sphinx-doc/sphinx/issues/4979)
   It should be removed once that issue is fixed.

.. exn:: No such goal. Try unfocusing with %}.
   :noindex:

   You just finished a goal focused by ``{``, you must unfocus it with ``}``.

Mandatory Bullets
~~~~~~~~~~~~~~~~~

Using :opt:`Default Goal Selector` with the ``!`` selector forces
tactic scripts to keep focus to exactly one goal (e.g. using bullets)
or use explicit goal selectors.

Set Bullet Behavior
~~~~~~~~~~~~~~~~~~~

.. opt:: Bullet Behavior {| "None" | "Strict Subproofs" }

   This :term:`option` controls the bullet behavior and can take two possible values:

   - "None": this makes bullets inactive.
   - "Strict Subproofs": this makes bullets active (this is the default behavior).

Modifying the order of goals
````````````````````````````

.. tacn:: cycle @int_or_var

   Reorders the selected goals so that the first :n:`@integer` goals appear after the
   other selected goals.
   If :n:`@integer` is negative, it puts the last :n:`@integer` goals at the
   beginning of the list.
   The tactic is only useful with a goal selector, most commonly `all:`.
   Note that other selectors reorder goals; `1,3: cycle 1` is not equivalent
   to `all: cycle 1`.  See :tacn:`… : … (goal selector)`.

.. example::

   .. coqtop:: none reset

      Parameter P : nat -> Prop.

   .. coqtop:: all abort

      Goal P 1 /\ P 2 /\ P 3 /\ P 4 /\ P 5.
      repeat split.
      all: cycle 2.
      all: cycle -3.

.. tacn:: swap @int_or_var @int_or_var

   Exchanges the position of the specified goals.
   Negative values for :n:`@integer` indicate counting goals
   backward from the end of the list of selected goals. Goals are indexed from 1.
   The tactic is only useful with a goal selector, most commonly `all:`.
   Note that other selectors reorder goals; `1,3: swap 1 3` is not equivalent
   to `all: swap 1 3`.  See :tacn:`… : … (goal selector)`.

.. example::

   .. coqtop:: all abort

      Goal P 1 /\ P 2 /\ P 3 /\ P 4 /\ P 5.
      repeat split.
      all: swap 1 3.
      all: swap 1 -1.

.. tacn:: revgoals

   Reverses the order of the selected goals.  The tactic is only useful with a goal
   selector, most commonly `all :`.   Note that other selectors reorder goals;
   `1,3: revgoals` is not equivalent to `all: revgoals`.  See :tacn:`… : … (goal selector)`.

   .. example::

      .. coqtop:: all abort

         Goal P 1 /\ P 2 /\ P 3 /\ P 4 /\ P 5.
         repeat split.
         all: revgoals.

Postponing the proof of some goals
``````````````````````````````````

Goals can be :gdef:`shelved` so they are no longer displayed in the proof state.
They can then be :gdef:`unshelved` to make them visible again.

.. tacn:: shelve

   This tactic moves all goals under focus to a shelf. While on the
   shelf, goals will not be focused on. They can be solved by
   unification, or they can be called back into focus with the command
   :cmd:`Unshelve`.

   .. tacn:: shelve_unifiable

      Shelves only the goals under focus that are mentioned in other goals.
      Goals that appear in the type of other goals can be solved by unification.

      .. example::

         .. coqtop:: all abort

            Goal exists n, n=0.
            refine (ex_intro _ _ _).
            all: shelve_unifiable.
            reflexivity.

.. cmd:: Unshelve

   This command moves all the goals on the shelf (see :tacn:`shelve`)
   from the shelf into focus, by appending them to the end of the current
   list of focused goals.

.. tacn:: unshelve @ltac_expr1

   Performs :n:`@tactic`, then unshelves existential variables added to the
   shelf by the execution of :n:`@tactic`, prepending them to the current goal.

.. tacn:: give_up

   This tactic removes the focused goals from the proof. They are not
   solved, and cannot be solved later in the proof. As the goals are not
   solved, the proof cannot be closed.

   The ``give_up`` tactic can be used while editing a proof, to choose to
   write the proof script in a non-sequential order.

.. _requestinginformation:

Requesting information
----------------------


.. cmd:: Show {? {| @ident | @natural } }

   Displays the current goals.

   :n:`@natural`
     Display only the :token:`natural`\-th goal.

   :n:`@ident`
     Displays the named goal :token:`ident`. This is useful in
     particular to display a shelved goal but only works if the
     corresponding existential variable has been named by the user
     (see :ref:`existential-variables`) as in the following example.

     .. example::

        .. coqtop:: all abort

           Goal exists n, n = 0.
           eexists ?[n].
           Show n.

   .. exn:: No focused proof.
      :undocumented:

   .. exn:: No such goal.
      :undocumented:

.. cmd:: Show Proof {? Diffs {? removed } }

   Displays the proof term generated by the tactics
   that have been applied so far. If the proof is incomplete, the term
   will contain holes, which correspond to subterms which are still to be
   constructed. Each hole is an existential variable, which appears as a
   question mark followed by an identifier.

   Specifying “Diffs” highlights the difference between the
   current and previous proof step.  By default, the command shows the
   output once with additions highlighted.  Including “removed” shows
   the output twice: once showing removals and once showing additions.
   It does not examine the :opt:`Diffs` option.  See :ref:`showing_proof_diffs`.

.. cmd:: Show Conjectures

   Prints the names of all the
   theorems that are currently being proved. As it is possible to start
   proving a previous lemma during the proof of a theorem, there may
   be multiple names.

.. cmd:: Show Intro

   If the current goal begins by at least one product,
   prints the name of the first product as it would be
   generated by an anonymous :tacn:`intro`. The aim of this command is to ease
   the writing of more robust scripts. For example, with an appropriate
   Proof General macro, it is possible to transform any anonymous :tacn:`intro`
   into a qualified one such as ``intro y13``. In the case of a non-product
   goal, it prints nothing.

.. cmd:: Show Intros

   Similar to the previous command.
   Simulates the naming process of :tacn:`intros`.

.. cmd:: Show Existentials

   Displays all open goals / existential variables in the current proof
   along with the context and type of each variable.

.. cmd:: Show Match @qualid

   Displays a template of the Gallina :token:`match<term_match>`
   construct with a branch for each constructor of the type
   :token:`qualid`.  This is used internally by
   `company-coq <https://github.com/cpitclaudel/company-coq>`_.

   .. example::

      .. coqtop:: all

         Show Match nat.

   .. exn:: Unknown inductive type.
      :undocumented:

.. cmd:: Show Universes

   Displays the set of all universe constraints and
   its normalized form at the current stage of the proof, useful for
   debugging universe inconsistencies.

.. cmd:: Show Goal @natural at @natural

   Available in coqtop.  Displays a goal at a
   proof state using the goal ID number and the proof state ID number.
   It is primarily for use by tools such as Prooftree that need to fetch
   goal history in this way.  Prooftree is a tool for visualizing a proof
   as a tree that runs in Proof General.

.. cmd:: Guarded

   Some tactics (e.g. :tacn:`refine`) allow to build proofs using
   fixpoint or co-fixpoint constructions. Due to the incremental nature
   of proof construction, the check of the termination (or
   guardedness) of the recursive calls in the fixpoint or cofixpoint
   constructions is postponed to the time of the completion of the proof.

   The command :cmd:`Guarded` allows checking if the guard condition for
   fixpoint and cofixpoint is violated at some time of the construction
   of the proof without having to wait the completion of the proof.

.. _showing_diffs:

Showing differences between proof steps
---------------------------------------

Coq can automatically highlight the differences between successive proof steps
and between values in some error messages.  Coq can also highlight differences
in the proof term.
For example, the following screenshots of CoqIDE and coqtop show the application
of the same :tacn:`intros` tactic.  The tactic creates two new hypotheses, highlighted in green.
The conclusion is entirely in pale green because although it’s changed, no tokens were added
to it.  The second screenshot uses the "removed" option, so it shows the conclusion a
second time with the old text, with deletions marked in red.  Also, since the hypotheses are
new, no line of old text is shown for them.

.. comment screenshot produced with:
   Inductive ev : nat -> Prop :=
   | ev_0 : ev 0
   | ev_SS : forall n : nat, ev n -> ev (S (S n)).

   Fixpoint double (n:nat) :=
     match n with
     | O => O
     | S n' => S (S (double n'))
     end.

   Goal forall n, ev n -> exists k, n = double k.
   intros n E.

..

  .. image:: ../../_static/diffs-coqide-on.png
     :alt: CoqIDE with Set Diffs on

..

  .. image:: ../../_static/diffs-coqide-removed.png
     :alt: CoqIDE with Set Diffs removed

..

  .. image:: ../../_static/diffs-coqtop-on3.png
     :alt: coqtop with Set Diffs on

This image shows an error message with diff highlighting in CoqIDE:

..

  .. image:: ../../_static/diffs-error-message.png
     :alt: CoqIDE error message with diffs

How to enable diffs
```````````````````

.. opt:: Diffs {| "on" | "off" | "removed" }

   This :term:`option` is used to enable diffs.
   The “on” setting highlights added tokens in green, while the “removed” setting
   additionally reprints items with removed tokens in red.  Unchanged tokens in
   modified items are shown with pale green or red.  Diffs in error messages
   use red and green for the compared values; they appear regardless of the setting.
   (Colors are user-configurable.)

For coqtop, showing diffs can be enabled when starting coqtop with the
``-diffs on|off|removed`` command-line option or by setting the :opt:`Diffs` option
within Coq.  You will need to provide the ``-color on|auto`` command-line option when
you start coqtop in either case.

Colors for coqtop can be configured by setting the ``COQ_COLORS`` environment
variable.  See section :ref:`customization-by-environment-variables`.  Diffs
use the tags ``diff.added``, ``diff.added.bg``, ``diff.removed`` and ``diff.removed.bg``.

In CoqIDE, diffs should be enabled from the ``View`` menu.  Don’t use the ``Set Diffs``
command in CoqIDE.  You can change the background colors shown for diffs from the
``Edit | Preferences | Tags`` panel by changing the settings for the ``diff.added``,
``diff.added.bg``, ``diff.removed`` and ``diff.removed.bg`` tags.  This panel also
lets you control other attributes of the highlights, such as the foreground
color, bold, italic, underline and strikeout.

Proof General can also display Coq-generated proof diffs automatically.
Please see the PG documentation section
"`Showing Proof Diffs" <https://proofgeneral.github.io/doc/master/userman/Coq-Proof-General#Showing-Proof-Diffs>`_)
for details.

How diffs are calculated
````````````````````````

Diffs are calculated as follows:

1. Select the old proof state to compare to, which is the proof state before
   the last tactic that changed the proof.  Changes that only affect the view
   of the proof, such as ``all: swap 1 2``, are ignored.

2. For each goal in the new proof state, determine what old goal to compare
   it to—the one it is derived from or is the same as.  Match the hypotheses by
   name (order is ignored), handling compacted items specially.

3. For each hypothesis and conclusion (the “items”) in each goal, pass
   them as strings to the lexer to break them into tokens.  Then apply the
   Myers diff algorithm :cite:`Myers` on the tokens and add appropriate highlighting.

Notes:

* Aside from the highlights, output for the "on" option should be identical
  to the undiffed output.
* Goals completed in the last proof step will not be shown even with the
  "removed" setting.

.. comment The following screenshots show diffs working with multiple goals and with compacted
   hypotheses.  In the first one, notice that the goal ``P 1`` is not highlighted at
   all after the split because it has not changed.

    .. todo: Use this script and remove the screenshots when COQ_COLORS
      works for coqtop in sphinx
    .. coqtop:: none

      Set Diffs "on".
      Parameter P : nat -> Prop.
      Goal P 1 /\ P 2 /\ P 3.

    .. coqtop:: out

      split.

    .. coqtop:: all abort

      2: split.

  ..

    .. coqtop:: none

      Set Diffs "on".
      Goal forall n m : nat, n + m = m + n.
      Set Diffs "on".

    .. coqtop:: out

       intros n.

    .. coqtop:: all abort

      intros m.

This screen shot shows the result of applying a :tacn:`split` tactic that replaces one goal
with 2 goals.  Notice that the goal ``P 1`` is not highlighted at all after
the split because it has not changed.

..

  .. image:: ../../_static/diffs-coqide-multigoal.png
     :alt: coqide with Set Diffs on with multiple goals

Diffs may appear like this after applying a :tacn:`intro` tactic that results
in a compacted hypotheses:

..

  .. image:: ../../_static/diffs-coqide-compacted.png
     :alt: coqide with Set Diffs on with compacted hypotheses

.. _showing_proof_diffs:

"Show Proof" differences
````````````````````````

To show differences in the proof term:

- In coqtop and Proof General, use the :cmd:`Show Proof` `Diffs` command.

- In CoqIDE, position the cursor on or just after a tactic to compare the proof term
  after the tactic with the proof term before the tactic, then select
  `View / Show Proof` from the menu or enter the associated key binding.
  Differences will be shown applying the current `Show Diffs` setting
  from the `View` menu.  If the current setting is `Don't show diffs`, diffs
  will not be shown.

  Output with the "added and removed" option looks like this:

  ..

    .. image:: ../../_static/diffs-show-proof.png
       :alt: coqide with Set Diffs on with compacted hypotheses

Controlling proof mode
----------------------


.. opt:: Hyps Limit @natural

   This :term:`option` controls the maximum number of hypotheses displayed in goals
   after the application of a tactic. All the hypotheses remain usable
   in the proof development.
   When unset, it goes back to the default mode which is to print all
   available hypotheses.


.. flag:: Nested Proofs Allowed

   When turned on (it is off by default), this :term:`flag` enables support for nested
   proofs: a new assertion command can be inserted before the current proof is
   finished, in which case Coq will temporarily switch to the proof of this
   *nested lemma*. When the proof of the nested lemma is finished (with :cmd:`Qed`
   or :cmd:`Defined`), its statement will be made available (as if it had been
   proved before starting the previous proof) and Coq will switch back to the
   proof of the previous assertion.

.. flag:: Printing Goal Names

   When this :term:`flag` is turned on, the name of the goal is printed in
   proof mode, which can be useful in cases of cross references
   between goals.

Controlling memory usage
------------------------

.. cmd:: Print Debug GC

   Prints heap usage statistics, which are values from the `stat` type of the `Gc` module
   described
   `here <https://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html#TYPEstat>`_
   in the OCaml documentation.
   The `live_words`, `heap_words` and `top_heap_words` values give the basic information.
   Words are 8 bytes or 4 bytes, respectively, for 64- and 32-bit executables.

When experiencing high memory usage the following commands can be used
to force Coq to optimize some of its internal data structures.

.. cmd:: Optimize Proof

   Shrink the data structure used to represent the current proof.


.. cmd:: Optimize Heap

   Perform a heap compaction.  This is generally an expensive operation.
   See: `OCaml Gc.compact <http://caml.inria.fr/pub/docs/manual-ocaml/libref/Gc.html#VALcompact>`_
   There is also an analogous tactic :tacn:`optimize_heap`.

Memory usage parameters can be set through the :ref:`OCAMLRUNPARAM <OCAMLRUNPARAM>`
environment variable.
