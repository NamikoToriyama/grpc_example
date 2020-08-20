package handler

import (
	"context"
	"fmt"
	"math/rand"
	"pancake/sample3/api/gen/api"
	"sync"
	"time"

	"github.com/golang/protobuf/ptypes/timestamp"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func init() {
	// パンケーキの仕上がりに影響するseedを初期化する
	rand.Seed(time.Now().UnixNano())
}

// BakerHandler パンケーキを焼く
type BakerHandler struct {
	report *report
}

type report struct {
	sync.Mutex // 同時に焼くよう
	data       map[api.Pancake_Menu]int
}

// NewBakerHandler ...BakerHandlerを初期化する
func NewBakerHandler() *BakerHandler {
	return &BakerHandler{
		report: &report{
			data: make(map[api.Pancake_Menu]int),
		},
	}
}

// Bake 指定されたメニューのパンケーキを焼いて，焼けたパンをResponseとして返す
func (h *BakerHandler) Bake(
	ctx context.Context,
	req *api.BakeRequest,
) (*api.BakeResponse, error) {
	fmt.Printf("Baked a pancake for %v\n", ctx.Value("Username"))
	// バリテーション
	if req.Menu == api.Pancake_UNKNOWN || req.Menu > api.Pancake_SPICY_CURRY {
		return nil, status.Errorf(codes.InvalidArgument, "パンケーキを選んでください")
	}

	// パンケーキを焼いて数を記録する
	now := time.Now()
	h.report.Lock()
	h.report.data[req.Menu]++
	h.report.Unlock()

	return &api.BakeResponse{
		Pancake: &api.Pancake{
			Menu:           req.Menu,
			ChefName:       "tori",
			TechnicalScore: rand.Float32(),
			CreateTime: &timestamp.Timestamp{
				Seconds: now.Unix(),
				Nanos:   int32(now.Nanosecond()),
			},
		},
	}, nil
}

// Report 焼けたパンケーキの数を返す
func (h *BakerHandler) Report(
	ctx context.Context,
	req *api.ReportRequest,
) (*api.ReportResponse, error) {
	counts := make([]*api.Report_BakeCount, 0)

	// レポート作成
	h.report.Lock()
	for k, v := range h.report.data {
		counts = append(counts, &api.Report_BakeCount{
			Menu:  k,
			Count: int32(v),
		})
	}
	h.report.Unlock()

	return &api.ReportResponse{
		Report: &api.Report{
			BakeCounts: counts,
		},
	}, nil

}
