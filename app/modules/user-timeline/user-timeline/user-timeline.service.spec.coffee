describe "tgUserTimelineService", ->
    provide = null
    $q = null
    $rootScope = null
    userTimelineService = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.users = {
            getTimeline: sinon.stub()
        }

        mocks.resources.projects = {
            getTimeline: sinon.stub()
        }

        provide.value "tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()

            return null

    _setup = ->
        _mocks()

    _inject = (callback) ->
        inject (_tgUserTimelineService_, _$q_, _$rootScope_) ->
            userTimelineService = _tgUserTimelineService_
            $q = _$q_
            $rootScope = _$rootScope_
            callback() if callback

    beforeEach ->
        module "taigaUserTimeline"
        _setup()
        _inject()

    valid_items = [
            { # valid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        "status": "xx",
                        "subject": "xx"
                    }
                }
            },
            { # invalid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        "fake": "xx"
                    }
                }
            },
            { # invalid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        "fake2": "xx"
                    }
                }
            },
            { # valid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        "fake2": "xx",
                        "milestone": "xx"
                    }
                }
            },
            { # invalid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        attachments: {
                            new: []
                        }
                    }
                }
            },
            { # valid item
                event_type: "xx.tt.create",
                data: {
                    values_diff: {
                        attachments: {
                            new: [1, 2]
                        }
                    }
                }
            },
            { # invalid item
                event_type: "xx.tt.delete",
                data: {
                    values_diff: {
                        attachments: {
                            new: [1, 2]
                        }
                    }
                }
            },
            { # invalid item
                event_type: "xx.project.change",
                data: {
                    values_diff: {
                        "name": "xx"
                    }
                }
            }
        ]

    it "filter invalid user timeline items", (done) ->
        userId = 3
        page = 2

        mocks.resources.users.getTimeline = (_userId_, _page_) ->
            expect(_userId_).to.be.equal(userId)
            expect(_page_).to.be.equal(page)

            return $q (resolve, reject) ->
                resolve(Immutable.fromJS(valid_items))

        userTimelineService.getTimeline(userId, page)
            .then (_items_) ->
                items = _items_.toJS()

                expect(items).to.have.length(3)
                expect(items[0]).to.be.eql(valid_items[0])
                expect(items[1]).to.be.eql(valid_items[3])
                expect(items[2]).to.be.eql(valid_items[5])

                done()

        $rootScope.$apply()

    it "filter invalid project timeline items", (done) ->
        projectId = 3
        page = 2

        mocks.resources.projects.getTimeline = (_projectId_, _page_) ->
            expect(_projectId_).to.be.equal(projectId)
            expect(_page_).to.be.equal(page)

            return $q (resolve, reject) ->
                resolve(Immutable.fromJS(valid_items))

        userTimelineService.getProjectTimeline(projectId, page)
            .then (_items_) ->
                items = _items_.toJS()

                expect(items).to.have.length(3)
                expect(items[0]).to.be.eql(valid_items[0])
                expect(items[1]).to.be.eql(valid_items[3])
                expect(items[2]).to.be.eql(valid_items[5])

                done()

        $rootScope.$apply()
